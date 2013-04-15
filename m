From: David Miller <davem@davemloft.net>
Subject: Re: net: mvneta: fix improper tx queue usage in mvneta_tx()
Date: Mon, 15 Apr 2013 14:08:37 -0400 (EDT)
Message-ID: <20130415.140837.1962205759703539734.davem@davemloft.net>
References: <20130415063537.GA26507@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	dima@marvell.com, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, bhutchings@solarflare.com,
	jason@lakedaemon.net, andrew@lunn.ch, alior@marvell.com,
	maen@marvell.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab3DOSIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:08:41 -0400
In-Reply-To: <20130415063537.GA26507@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 15 Apr 2013 08:35:37 +0200

> From 4f2069c92a27790e6071dc2a80f92c166e0b0ca4 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 11 Apr 2013 23:00:37 +0200
> Subject: net: mvneta: fix improper tx queue usage in mvneta_tx()
> 
> mvneta_tx() was using a static tx queue number causing crashes as
> soon as a little bit of traffic was sent via the interface, because
> it is normally expected that the same queue should be used as in
> dev_queue_xmit().
> 
> As suggested by Ben Hutchings, let's use skb_get_queue_mapping() to
> get the proper Tx queue number, and use alloc_etherdev_mqs() instead
> of alloc_etherdev_mq() to create the queues.
> 
> Both my Mirabox and my OpenBlocks AX3 used to crash without this patch
> and don't anymore with it. The issue appeared in 3.8 but became more
> visible after the fix allowing GSO to be enabled.
> 
> Original work was done by Dmitri Epshtein and Thomas Petazzoni. I
> just adapted it to take care of Ben's comments.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Applied.
