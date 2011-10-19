From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/8 RFC v2] rtnetlink: Add rtnl link operations
	for MAC address and VLAN filtering
Date: Tue, 18 Oct 2011 23:26:04 -0700
Message-ID: <20111019062604.7242.71829.stgit@savbu-pc100.cisco.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds the following rtnl_link_ops to set and get MAC and VLAN
filters

set_rx_addr_filter - to set address filter
set_rx_vlan_filter - To set vlan filter
get_rx_addr_filter_size - To get address filter size
get_rx_vlan_filter_size - To get vlan filter size
fill_rx_addr_filter - To fill addr filter
fill_rx_vlan_filter - To fill vlan filter

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/net/rtnetlink.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)


diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 678f1ff..dcb26bd 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -78,6 +78,19 @@ struct rtnl_link_ops {
 	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
 						 unsigned int *tx_queues,
 						 unsigned int *real_tx_queues);
+
+	int			(*set_rx_addr_filter)(struct net_device *dev,
+						      struct nlattr *tb[]);
+	int			(*set_rx_vlan_filter)(struct net_device *dev,
+						      struct nlattr *tb[]);
+	size_t			(*get_rx_addr_filter_size)(
+						const struct net_device *dev);
+	size_t			(*get_rx_vlan_filter_size)(
+						const struct net_device *dev);
+	int			(*fill_rx_addr_filter)(struct sk_buff *skb,
+						const struct net_device *dev);
+	int			(*fill_rx_vlan_filter)(struct sk_buff *skb,
+						const struct net_device *dev);
 };
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);

