From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 1/8] can: fix memory leak in initial namespace support
Date: Tue, 25 Apr 2017 08:19:38 +0200
Message-ID: <20170425061945.28722-2-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The can_rx_alldev_list is a per-net data structure now and allocated in
can_pernet_init(). Make sure the memory is free'd in can_pernet_exit() too.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/af_can.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index abf7d854a94d..2c935babe466 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -903,6 +903,8 @@ static void can_pernet_exit(struct net *net)
 		}
 	}
 	rcu_read_unlock();
+
+	kfree(net->can.can_rx_alldev_list);
 }
 
 /*
-- 
2.11.0

