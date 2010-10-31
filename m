From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: fix panic on load
Date: Sun, 31 Oct 2010 09:26:36 -0700 (PDT)
Message-ID: <20101031.092636.193730282.davem@davemloft.net>
References: <1288539978.2660.47.camel@edumazet-laptop>
	<20101031163428.M61655@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756130Ab0JaQ0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 12:26:12 -0400
In-Reply-To: <20101031163428.M61655@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 1 Nov 2010 00:39:14 +0800

> On Sun, 31 Oct 2010 16:46:18 +0100, Eric Dumazet wrote
> Can this patch be modified to move the netif_stop_queue()
> after register_netdev() ?
> It seems the __QUEUE_STATE_XOFF is not set after the register_netdev.
> The tx_queue was kcalloc() ed without touching state flags.

At the veyr moment that register_netdev() is called, the
->open() method of your driver can be invoked and the
queue state changed.

So no, you can't put it after the register call.

There is zero reason to touch the queue state in your
probe routine, the state of the queue before ->open()
is "don't care".

Eric's patch is going to be applied, it is correct.
