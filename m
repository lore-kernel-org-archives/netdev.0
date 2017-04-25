From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 2/8] can: remove obsolete pernet_operations definitions
Date: Tue, 25 Apr 2017 08:19:39 +0200
Message-ID: <20170425061945.28722-3-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The namespace support for the CAN subsystem does not need any additional
memory. So when ".size = 0" there's no extra memory allocated by the system.
And therefore ".id" is obsolete too.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/af_can.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 2c935babe466..421b60fc42c3 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -75,8 +75,6 @@ static int stats_timer __read_mostly = 1;
 module_param(stats_timer, int, S_IRUGO);
 MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 
-static int can_net_id;
-
 static struct kmem_cache *rcv_cache __read_mostly;
 
 /* table of registered CAN protocols */
@@ -935,8 +933,6 @@ static struct notifier_block can_netdev_notifier __read_mostly = {
 static struct pernet_operations can_pernet_ops __read_mostly = {
 	.init = can_pernet_init,
 	.exit = can_pernet_exit,
-	.id = &can_net_id,
-	.size = 0,
 };
 
 static __init int can_init(void)
-- 
2.11.0

