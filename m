From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] e1000: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 18:05:30 +0100
Message-ID: <20080718170529.GD10471@solarflare.com>
References: <20080718.033947.193705552.davem@davemloft.net> <20080718165128.GC10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:41052 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757025AbYGRRFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 13:05:36 -0400
Content-Disposition: inline
In-Reply-To: <20080718165128.GC10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent changes to tx mutiqueue, e1000 was not calling
netif_start_queue() before calling netif_wake_queue().
This causes an oops during loading of the driver.

(Based on commit d55b53fff0c2ddb639dca04c3f5a0854f292d982.)

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f8df8bd..cf12b05 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1472,6 +1472,8 @@ e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
+	netif_start_queue(netdev);
+
 	/* fire a link status change interrupt to start the watchdog */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
