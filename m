From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 13:25:25 +0100
Message-ID: <1303215925.3464.54.camel@localhost>
References: <4DAD5753.4040108@monstr.eu>
	 <1303209787.3480.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:52699 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab1DSMZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 08:25:28 -0400
In-Reply-To: <1303209787.3480.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 12:43 +0200, Eric Dumazet wrote:
[...]
> One possible way to get better performance is to change driver to
> allocate skbs only right before calling netif_rx(), so that you dont
> have to access cold sk_buff data twice (once when allocating skb and put
> it in ring buffer, a second time when receiving frame)
>
> drivers/net/niu.c is a good example for this (NAPI + netdev_alloc_skb()
> just in time + pull in skbhead only first cache line of packet)
[...]

If the hardware can do RX checksumming (it's not clear) then the driver
should pass the paged buffers into GRO and that will take care of skb
allocation as necessary.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

