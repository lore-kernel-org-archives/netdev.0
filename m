From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 8/8 RFC v2] macvtap: Add support to get MAC/VLAN
	filter rtnl link operations
Date: Tue, 18 Oct 2011 23:26:36 -0700
Message-ID: <20111019062636.7242.46889.stgit@savbu-pc100.cisco.com>
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

This patch adds support to get MAC and VLAN filter rtnl_link_ops
on a macvtap interface. It adds support for get_rx_addr_filter_size,
get_rx_vlan_filter_size, fill_rx_addr_filter and fill_rx_vlan_filter
rtnl link operations. Calls equivalent macvlan operations.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvtap.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)


diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8a2cb59..9b40de7 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -285,6 +285,29 @@ static int macvtap_set_rx_vlan_filter(struct net_device *dev,
 	return macvlan_set_rx_vlan_filter(dev, tb);
 }
 
+static int macvtap_fill_rx_addr_filter(struct sk_buff *skb,
+	const struct net_device *dev)
+{
+	return macvlan_fill_rx_addr_filter(skb, dev);
+}
+
+static int macvtap_fill_rx_vlan_filter(struct sk_buff *skb,
+	const struct net_device *dev)
+{
+	return macvlan_fill_rx_vlan_filter(skb, dev);
+}
+
+static size_t macvtap_get_rx_addr_filter_size(const struct net_device *dev)
+{
+	return macvlan_get_rx_addr_filter_size(dev);
+}
+
+static size_t macvtap_get_rx_vlan_filter_size(const struct net_device *dev)
+{
+	return macvlan_get_rx_vlan_filter_size(dev);
+}
+
+
 static int macvtap_newlink(struct net *src_net,
 			   struct net_device *dev,
 			   struct nlattr *tb[],
@@ -335,6 +358,10 @@ static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
 	.dellink			= macvtap_dellink,
 	.set_rx_addr_filter		= macvtap_set_rx_addr_filter,
 	.set_rx_vlan_filter		= macvtap_set_rx_vlan_filter,
+	.get_rx_addr_filter_size	= macvtap_get_rx_addr_filter_size,
+	.get_rx_vlan_filter_size	= macvtap_get_rx_vlan_filter_size,
+	.fill_rx_addr_filter		= macvtap_fill_rx_addr_filter,
+	.fill_rx_vlan_filter		= macvtap_fill_rx_vlan_filter,
 };
 
 

