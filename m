From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] et131x: use msecs_to_jiffies for conversions
Date: Wed, 11 Feb 2015 04:27:54 -0500
Message-ID: <1423646874-24403-1-git-send-email-hofrat@osadl.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable.
Converting milliseconds to jiffies by "val * HZ / 1000" is technically
OK but msecs_to_jiffies(val) is the cleaner solution and handles all
corner cases correctly. This is a minor API cleanup only.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was compile-tested only for x86_64_defconfig + CONFIG_ET131X=m

Patch is against 3.19.0 (localversion-next is -next-20150211)

 drivers/net/ethernet/agere/et131x.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 384dc16..9e78bc7 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3127,7 +3127,8 @@ static void et131x_error_timer_handler(unsigned long data)
 	}
 
 	/* This is a periodic timer, so reschedule */
-	mod_timer(&adapter->error_timer, jiffies + TX_ERROR_PERIOD * HZ / 1000);
+	mod_timer(&adapter->error_timer, jiffies +
+		  msecs_to_jiffies(TX_ERROR_PERIOD));
 }
 
 static void et131x_adapter_memory_free(struct et131x_adapter *adapter)
@@ -3647,7 +3648,8 @@ static int et131x_open(struct net_device *netdev)
 
 	/* Start the timer to track NIC errors */
 	init_timer(&adapter->error_timer);
-	adapter->error_timer.expires = jiffies + TX_ERROR_PERIOD * HZ / 1000;
+	adapter->error_timer.expires = jiffies +
+		msecs_to_jiffies(TX_ERROR_PERIOD);
 	adapter->error_timer.function = et131x_error_timer_handler;
 	adapter->error_timer.data = (unsigned long)adapter;
 	add_timer(&adapter->error_timer);
-- 
1.7.10.4
