From: David Decotigny <decot@google.com>
Subject: [PATCH 1/3] net-bonding: Fix minor sparse complaints
Date: Wed, 13 Apr 2011 18:22:29 -0700
Message-ID: <1302744151-12452-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This gets rid of minor sparse complaints:
drivers/net/bonding/bond_main.c:4361:4: warning: do-while statement is not a compound statement
drivers/net/bonding/bond_main.c:243:12: warning: symbol 'bond_mode_name' was not declared. Should it be static?

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/bonding/bond_main.c   |    4 ++--
 drivers/net/bonding/bond_procfs.c |    2 --
 drivers/net/bonding/bonding.h     |    1 +
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 16d6fe9..8264ed7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4357,9 +4357,9 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
 
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
-		do
+		do {
 			txq -= dev->real_num_tx_queues;
-		while (txq >= dev->real_num_tx_queues);
+		} while (txq >= dev->real_num_tx_queues);
 	}
 	return txq;
 }
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index c32ff55..c97307d 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -4,8 +4,6 @@
 #include "bonding.h"
 
 
-extern const char *bond_mode_name(int mode);
-
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 	__acquires(&bond->lock)
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 90736cb..3ca503e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -416,6 +416,7 @@ void bond_destroy_debugfs(void);
 void bond_debug_register(struct bonding *bond);
 void bond_debug_unregister(struct bonding *bond);
 void bond_debug_reregister(struct bonding *bond);
+const char *bond_mode_name(int mode);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */
-- 
1.7.3.1
