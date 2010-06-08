From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] r8169: fix random mdio_write failures
Date: Tue, 08 Jun 2010 09:06:04 +0300
Message-ID: <4C0DDDCC.6010500@iki.fi>
References: <4C0A1736.9030209@iki.fi> <1275733273-28321-1-git-send-email-timo.teras@iki.fi> <20100605124103.GA3213@electric-eye.fr.zoreil.com> <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw> <20100607215115.GA6583@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:46957 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab0FHGGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 02:06:08 -0400
Received: by ewy23 with SMTP id 23so1698ewy.1
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 23:06:06 -0700 (PDT)
In-Reply-To: <20100607215115.GA6583@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2010 12:51 AM, Francois Romieu wrote:
> hayeswang <hayeswang@realtek.com> :
>> Our hardware engineer suggests that check the completed indication
>> per 100 micro seconds. And it needs 20 micro seconds delay after the 
>> completed indication for the next command.
> 
> Should we do the same for mdio_read as well (100 us per iteration + 
> an extra 20 us) ?

Well, doing 100us per iteration will increase the latency that the code
notices "write complete" which slows down things. It'll also slightly
decrease bus traffic which is good. But I'd be just fine with 25us per
iteration. It sounds unlikely that polling the status register would
slow down the actual write operation (if that is the case then 100us
would be desirable).

Changing my 25us to 20us would good. The original 25us was just a guess.
The comment should be probably also updated that those delays are from
realtek hw specs then.

Would you like me to send a patch?

- Timo


