From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH] jme: fix panic on load
Date: Mon, 1 Nov 2010 19:22:32 +0800
Message-ID: <20101101112159.M24173@cooldavid.org>
References: <1288539978.2660.47.camel@edumazet-laptop> <20101031163428.M61655@cooldavid.org> <20101031.092636.193730282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:51654 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754890Ab0KAK4s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 06:56:48 -0400
In-Reply-To: <20101031.092636.193730282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 31 Oct 2010 09:26:36 -0700 (PDT), David Miller wrote
> From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
> Date: Mon, 1 Nov 2010 00:39:14 +0800
> 
> > On Sun, 31 Oct 2010 16:46:18 +0100, Eric Dumazet wrote
> > Can this patch be modified to move the netif_stop_queue()
> > after register_netdev() ?
> > It seems the __QUEUE_STATE_XOFF is not set after the register_netdev.
> > The tx_queue was kcalloc() ed without touching state flags.
> 
> At the veyr moment that register_netdev() is called, the
> ->open() method of your driver can be invoked and the
> queue state changed.
> 
> So no, you can't put it after the register call.
> 
> There is zero reason to touch the queue state in your
> probe routine, the state of the queue before ->open()
> is "don't care".
> 
> Eric's patch is going to be applied, it is correct.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
I see.
Thanks for the info. :)

Guo-Fu Tseng

