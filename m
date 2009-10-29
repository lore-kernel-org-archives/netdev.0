From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 16:58:07 -0700
Message-ID: <20091029235807.GF3228@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52219 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033AbZJ2X6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 19:58:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before bringing up a sky2 interface up ethtool reports 
"Link detected: yes". Do as ixgbe does and netif_carrier_off() on
probe().

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/sky2.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -4538,6 +4538,8 @@ static int __devinit sky2_probe(struct p
 		goto err_out_free_netdev;
 	}
 
+	netif_carrier_off(dev);
+
 	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
 
 	err = request_irq(pdev->irq, sky2_intr,
