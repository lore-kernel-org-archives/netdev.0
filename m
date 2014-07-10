From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 20/33] net: irlan - set name assign type
Date: Thu, 10 Jul 2014 10:17:25 +0200
Message-ID: <1404980258-30853-21-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Samuel Ortiz <samuel@sortiz.org>,
	Dragos Foianu <dragos.foianu@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: Dragos Foianu <dragos.foianu@gmail.com>
---
 include/net/irda/irlan_eth.h  | 2 +-
 net/irda/irlan/irlan_common.c | 2 +-
 net/irda/irlan/irlan_eth.c    | 7 ++++---
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/irda/irlan_eth.h b/include/net/irda/irlan_eth.h
index de5c816..00fd2f8 100644
--- a/include/net/irda/irlan_eth.h
+++ b/include/net/irda/irlan_eth.h
@@ -25,7 +25,7 @@
 #ifndef IRLAN_ETH_H
 #define IRLAN_ETH_H
 
-struct net_device *alloc_irlandev(const char *name);
+struct net_device *alloc_irlandev(const char *name, unsigned char name_assign_type);
 int  irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb);
 
 void irlan_eth_flow_indication( void *instance, void *sap, LOCAL_FLOW flow);
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 7ac4d1b..5a458b0 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -204,7 +204,7 @@ static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Create network device with irlan */
-	dev = alloc_irlandev(eth ? "eth%d" : "irlan%d");
+	dev = alloc_irlandev(eth ? "eth%d" : "irlan%d", NET_NAME_ENUM);
 	if (!dev)
 		return NULL;
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index dc13f1a..b62a822 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -94,10 +94,11 @@ static void irlan_eth_setup(struct net_device *dev)
  *    Allocate network device and control block
  *
  */
-struct net_device *alloc_irlandev(const char *name)
+struct net_device *alloc_irlandev(const char *name,
+				  unsigned char name_assign_type)
 {
-	return alloc_netdev(sizeof(struct irlan_cb), name, NET_NAME_UNKNOWN,
-			    irlan_eth_setup);
+	return alloc_netdev(sizeof(struct irlan_cb), name,
+			    name_assign_type, irlan_eth_setup);
 }
 
 /*
-- 
1.9.3
