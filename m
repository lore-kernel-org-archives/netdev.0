From: Daniel Drake <dsd@gentoo.org>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Fri, 09 Jun 2006 16:29:13 +0100
Message-ID: <448993C9.8040400@gentoo.org>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:15614 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965287AbWFIP2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 11:28:13 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Daniel Drake <dsd@gentoo.org> wrote:
>> More specifically, we're talking about drivers/usb/net/usbnet.c and the 
>> usbnet_disconnect() function.  The race I am highlighting is that 
>> usbnet's hard_start_xmit handler (usbnet_start_xmit) may be running when 
>> the disconnect happens.
>>
>> Is this a possible scenario?
> 
> It should be safe, if only because of the synchronize_net that occurs
> before a netdev can be freed.

Can I interpret your response as: If the TX queue is disabled in 
advance, no hard_start_xmit functions will be running on any CPU after 
synchronize_net() has returned?

The synchronize_net() code doesn't make it very clear.

Thanks,
Daniel
