From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 20/26] ixgb: Set a constant blink rate for ixgb adapter identify (1sec on, 1sec off)
Date: Tue, 29 Aug 2006 09:44:59 -0700
Message-ID: <20060829164459.6872.43657.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53258 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965093AbWH2Qgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:45 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index cf19b89..ba62108 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -654,11 +654,7 @@ ixgb_phys_id(struct net_device *netdev, 
 
 	mod_timer(&adapter->blink_timer, jiffies);
 
-	if (data)
-		schedule_timeout_interruptible(data * HZ);
-	else
-		schedule_timeout_interruptible(MAX_SCHEDULE_TIMEOUT);
-
+	msleep_interruptible(data * 1000);
 	del_timer_sync(&adapter->blink_timer);
 	ixgb_led_off(&adapter->hw);
 	clear_bit(IXGB_LED_ON, &adapter->led_status);



---
Auke Kok <auke-jan.h.kok@intel.com>
