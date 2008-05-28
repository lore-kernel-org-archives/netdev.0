From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Tue, 27 May 2008 18:18:57 -0700
Message-ID: <483CB301.40007@sun.com>
References: <20080526.123338.161271834.davem@davemloft.net>
 <20080526.123951.260448303.davem@davemloft.net> <483B239D.4090402@krogh.cc>
 <20080526.151540.191673092.davem@davemloft.net> <483BA80C.4020502@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:42948 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbYE1BS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 21:18:59 -0400
In-reply-to: <483BA80C.4020502@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:

> David Miller wrote:
>
>> From: Jesper Krogh <jesper@krogh.cc>
>> Date: Mon, 26 May 2008 22:54:53 +0200
>>
>>> Applied and running.. I've now pushed 400GB of data through it 
>>> trying to
>>> get it to hit the bug but it is still running.
>>>
>>> So without saying that it solved the problem, it definately seems so.
>>> 2.6.26-rc4 + above patch.
>>
>>
>> Thanks for testing.
>
>
> Ok. I was too early out.. it ended up in the same situation again.
>
> May 27 08:09:12 hest kernel: [42953871.982072] NETDEV WATCHDOG: eth4: 
> transmit timed out
> May 27 08:09:17 hest kernel: [42953877.827797] NETDEV WATCHDOG: eth4: 
> transmit timed out
> May 27 08:09:22 hest kernel: [42953883.958375] NETDEV WATCHDOG: eth4: 
> transmit timed out
> May 27 08:09:27 hest kernel: [42953890.668401] NETDEV WATCHDOG: eth4: 
> transmit timed out
>
>
> Jesper

Dave,
Considering that fixing the HW would take considerable time, I was 
wondering if the scheme we use in the nxge driver could be considered as 
a workaround. Since the niu driver is already doing skb_orphan as a work 
around, what if  already transmitted TX buffers are  reclaimed 
periodically, within dev->hard_start_xmit() ?  Then TX_DESC_MARK would 
be set if/when available TX descriptor count falls below some watermark. 
Disable device TX queue about the time  TX_DESC_MARK is set and enable 
it within TX interrupt.

Regards
Matheos


