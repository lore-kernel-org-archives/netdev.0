From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 7/8 RFC v2] macvtap: Add support to set MAC/VLAN
	filter rtnl link operations
Date: Tue, 18 Oct 2011 23:26:30 -0700
Message-ID: <20111019062630.7242.99374.stgit@savbu-pc100.cisco.com>
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

This patch adds support to set MAC and VLAN filter rtnl_link_ops
on a macvtap interface. It adds support for set_rx_addr_filter and
set_rx_vlan_filter rtnl link operations. These operations inturn call the
equivalent operations defined in macvlan

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvtap.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)


diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3da5578..8a2cb59 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -273,6 +273,18 @@ static int macvtap_receive(struct sk_buff *skb)
 	return macvtap_forward(skb->dev, skb);
 }
 
+static int macvtap_set_rx_addr_filter(struct net_device *dev,
+	struct nlattr *tb[])
+{
+	return macvlan_set_rx_addr_filter(dev, tb);
+}
+
+static int macvtap_set_rx_vlan_filter(struct net_device *dev,
+	struct nlattr *tb[])
+{
+	return macvlan_set_rx_vlan_filter(dev, tb);
+}
+
 static int macvtap_newlink(struct net *src_net,
 			   struct net_device *dev,
 			   struct nlattr *tb[],
@@ -317,10 +329,12 @@ static void macvtap_setup(struct net_device *dev)
 }
 
 static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
-	.kind		= "macvtap",
-	.setup		= macvtap_setup,
-	.newlink	= macvtap_newlink,
-	.dellink	= macvtap_dellink,
+	.kind				= "macvtap",
+	.setup				= macvtap_setup,
+	.newlink			= macvtap_newlink,
+	.dellink			= macvtap_dellink,
+	.set_rx_addr_filter		= macvtap_set_rx_addr_filter,
+	.set_rx_vlan_filter		= macvtap_set_rx_vlan_filter,
 };
 
 

