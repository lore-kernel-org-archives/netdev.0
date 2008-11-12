From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 15:10:34 -0800
Message-ID: <491B626A.6020801@sun.com>
References: <20081112.014923.68124784.davem@davemloft.net>
 <1226487710.6834.53.camel@localhost.localdomain>
 <20081112.035240.226243372.davem@davemloft.net>
 <20081112.041143.11487260.davem@davemloft.net>
 <Pine.LNX.4.64.0811122213180.1212@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:45218 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbYKLXNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 18:13:17 -0500
In-reply-to: <Pine.LNX.4.64.0811122213180.1212@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:

>
> Hi Google,
>
> On Wed, 12 Nov 2008, David Miller wrote:
>
>> Guess what that does?  The packet counters live in the upper
>> 32-bits and the MARK bits live in the lower 32-bits of the
>> TX_CS register.
>>
>> So it first reads the packet counters, and as a side effect that
>> clears the MARK bits in the TX_CS register.  So when we read the lower
>> 32-bits the MARK bits are always seen as zero.
>
>
> For the thorough reader, the TX_CS Transmit Control and Status 
> register is described in table 26-15 page 761-762 in the PDF document 
> titled: "UltraSPARC T2 supplement to UltraSPARC architecture 2007", 
> downloadable from: 
> http://opensparc-t2.sunsource.net/specs/UST2-UASuppl-current-draft-HP-EXT.pdf 
>
>
> Cheers,
>   Jesper Brouer
>
> -- 
> -------------------------------------------------------------------
> MSc. Master of Computer Science
> Dept. of Computer Science, University of Copenhagen
> Author of http://www.adsl-optimizer.dk
> -------------------------------------------------------------------
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The niu/neptune HW puts some requirement on 32 bit reads of 64 bit 
registers. You need to read the lower 32 bits first and then the upper 
32 bits.  The same ordering applies to writes as well.
On some 64 bit platforms, the 64 bit reads  are split into two 32 bit 
reads as well, regardless of the OS.

Regards
Matheos

