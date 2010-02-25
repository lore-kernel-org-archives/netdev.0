From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] greth: fall through to common return statement on error
Date: Fri, 26 Feb 2010 10:50:19 +1100
Message-ID: <20100225235019.GA26133@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kristoffer Glembo <kristoffer@gaisler.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58823 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934553Ab0BYXuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 18:50:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There doesn't seem to be any reason to explicitly return
NETDEV_TX_OK as err is set to NETDEV_TX_OK in all cases that
reach this point.

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Cosmetic change brought about by curiosity as to weather returning
NETDEV_TX_OK on these error conditions is correct. I have similar
curiosity relating to greth_start_xmit().

Index: net-next-2.6/drivers/net/greth.c
===================================================================
--- net-next-2.6.orig/drivers/net/greth.c	2010-02-26 10:42:35.000000000 +1100
+++ net-next-2.6/drivers/net/greth.c	2010-02-26 10:42:55.000000000 +1100
@@ -556,8 +556,6 @@ map_error:
 	if (net_ratelimit())
 		dev_warn(greth->dev, "Could not create TX DMA mapping\n");
 	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
-
 out:
 	return err;
 }
