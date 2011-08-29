From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/24] atm: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:22 -0700
Message-ID: <af6564f9301e7a3db39491238154fdd7172fea8a.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c         |    4 +---
 net/atm/mpc.c         |   17 +++++------------
 net/atm/mpoa_caches.c |    8 ++------
 3 files changed, 8 insertions(+), 21 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index f1964ca..6dc635c 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1674,10 +1674,8 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 	struct lec_arp_table *to_return;
 
 	to_return = kzalloc(sizeof(struct lec_arp_table), GFP_ATOMIC);
-	if (!to_return) {
-		pr_info("LEC: Arp entry kmalloc failed\n");
+	if (!to_return)
 		return NULL;
-	}
 	memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
 	INIT_HLIST_NODE(&to_return->next);
 	setup_timer(&to_return->timer, lec_arp_expire_arp,
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index aa97240..fc85df0 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -184,10 +184,8 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 	}
 
 	entry = kmalloc(sizeof(struct atm_mpoa_qos), GFP_KERNEL);
-	if (entry == NULL) {
-		pr_info("mpoa: out of memory\n");
+	if (entry == NULL)
 		return entry;
-	}
 
 	entry->ipaddr = dst_ip;
 	entry->qos = *qos;
@@ -473,10 +471,8 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
 			kfree(mpc->mps_macs);
 		mpc->number_of_mps_macs = 0;
 		mpc->mps_macs = kmalloc(num_macs * ETH_ALEN, GFP_KERNEL);
-		if (mpc->mps_macs == NULL) {
-			pr_info("(%s) out of mem\n", mpc->dev->name);
+		if (mpc->mps_macs == NULL)
 			return NULL;
-		}
 	}
 	memcpy(mpc->mps_macs, router_mac, ETH_ALEN);
 	tlvs += 20; if (device_type == MPS_AND_MPC) tlvs += 20;
@@ -1260,10 +1256,8 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	}
 
 	skb = alloc_skb(sizeof(struct k_message), GFP_ATOMIC);
-	if (skb == NULL) {
-		pr_info("out of memory\n");
+	if (skb == NULL)
 		return;
-	}
 
 	skb_put(skb, sizeof(struct k_message));
 	memset(skb->data, 0, sizeof(struct k_message));
@@ -1379,10 +1373,9 @@ static void set_mps_mac_addr_rcvd(struct k_message *msg,
 		kfree(client->mps_macs);
 	client->number_of_mps_macs = 0;
 	client->mps_macs = kmemdup(msg->MPS_ctrl, ETH_ALEN, GFP_KERNEL);
-	if (client->mps_macs == NULL) {
-		pr_info("out of memory\n");
+	if (client->mps_macs == NULL)
 		return;
-	}
+
 	client->number_of_mps_macs = 1;
 }
 
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index d1b2d9a..cc5f46d 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -98,10 +98,8 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 {
 	in_cache_entry *entry = kzalloc(sizeof(in_cache_entry), GFP_KERNEL);
 
-	if (entry == NULL) {
-		pr_info("mpoa: mpoa_caches.c: new_in_cache_entry: out of memory\n");
+	if (entry == NULL)
 		return NULL;
-	}
 
 	dprintk("adding an ingress entry, ip = %pI4\n", &dst_ip);
 
@@ -460,10 +458,8 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 {
 	eg_cache_entry *entry = kzalloc(sizeof(eg_cache_entry), GFP_KERNEL);
 
-	if (entry == NULL) {
-		pr_info("out of memory\n");
+	if (entry == NULL)
 		return NULL;
-	}
 
 	dprintk("adding an egress entry, ip = %pI4, this should be our IP\n",
 		&msg->content.eg_info.eg_dst_ip);
-- 
1.7.6.405.gc1be0
