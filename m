From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: fix tx timeout
Date: Fri, 23 Mar 2007 05:50:02 -0500
Message-ID: <4603B0DA.7070908@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070900090702010302040705"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:1806 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992590AbXCWWDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 18:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070900090702010302040705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The tx timeout routine was waking the tx queue conditionally. However, 
it must call it unconditionally since the dev_watchdog has halted the tx 
queue before calling the timeout function.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070900090702010302040705
Content-Type: text/plain;
 name="patch-forcedeth-fix-timeout"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-fix-timeout"

--- orig/drivers/net/forcedeth.c	2007-03-11 20:59:06.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-03-11 20:58:59.000000000 -0500
@@ -2050,9 +2050,10 @@
 		nv_drain_tx(dev);
 		nv_init_tx(dev);
 		setup_hw_rings(dev, NV_SETUP_TX_RING);
-		netif_wake_queue(dev);
 	}
 
+	netif_wake_queue(dev);
+
 	/* 4) restart tx engine */
 	nv_start_tx(dev);
 	spin_unlock_irq(&np->lock);

--------------070900090702010302040705--
