From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/3] bonding: More use of ether_addr_copy
Date: Tue, 18 Feb 2014 09:42:45 -0800
Message-ID: <e0827821f932f8c8ad3b2b32c7ffe7ce8a9e0d90.1392745013.git.joe@perches.com>
References: <cover.1392745013.git.joe@perches.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392745013.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's smaller and faster for some architectures.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_3ad.c  | 4 ++--
 drivers/net/bonding/bond_alb.c  | 5 ++---
 drivers/net/bonding/bond_main.c | 6 +++---
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index e9edd84..7cb51f9 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2386,8 +2386,8 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 		ad_info->ports = aggregator->num_of_ports;
 		ad_info->actor_key = aggregator->actor_oper_aggregator_key;
 		ad_info->partner_key = aggregator->partner_oper_aggregator_key;
-		memcpy(ad_info->partner_system,
-		       aggregator->partner_system.mac_addr_value, ETH_ALEN);
+		ether_addr_copy(ad_info->partner_system,
+				aggregator->partner_system.mac_addr_value);
 		return 0;
 	}
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 538913e..97a43a20 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1449,9 +1449,8 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 
 	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
 		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
-			memcpy(eth_data->h_source,
-			       tx_slave->dev->dev_addr,
-			       ETH_ALEN);
+			ether_addr_copy(eth_data->h_source,
+					tx_slave->dev->dev_addr);
 		}
 
 		bond_dev_queue_xmit(bond, skb, tx_slave->dev);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3bce855..4690b11 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -674,8 +674,8 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 
 		if (old_active) {
 			ether_addr_copy(tmp_mac, new_active->dev->dev_addr);
-			memcpy(saddr.sa_data, old_active->dev->dev_addr,
-			       ETH_ALEN);
+			ether_addr_copy(saddr.sa_data,
+					old_active->dev->dev_addr);
 			saddr.sa_family = new_active->dev->type;
 		} else {
 			ether_addr_copy(saddr.sa_data, bond->dev->dev_addr);
@@ -1142,7 +1142,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 			kfree_skb(skb);
 			return RX_HANDLER_CONSUMED;
 		}
-		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
+		ether_addr_copy(eth_hdr(skb)->h_dest, bond->dev->dev_addr);
 	}
 
 	return ret;
-- 
1.8.1.2.459.gbcd45b4.dirty
