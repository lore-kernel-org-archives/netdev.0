From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 2/11] [ATM]: Use kmemdup & kzalloc where applicable
Date: Tue, 21 Nov 2006 01:27:16 -0200
Message-ID: <20061121032715.GC7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:4589 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030682AbWKUD1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:27:23 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/atm/lec.c         |   10 +++-------
 net/atm/mpc.c         |    3 +--
 net/atm/mpoa_caches.c |    6 ++----
 3 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 9f5f931..5946ec6 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1321,11 +1321,10 @@ static int lane2_resolve(struct net_devi
 		if (table == NULL)
 			return -1;
 
-		*tlvs = kmalloc(table->sizeoftlvs, GFP_ATOMIC);
+		*tlvs = kmemdup(table->tlvs, table->sizeoftlvs, GFP_ATOMIC);
 		if (*tlvs == NULL)
 			return -1;
 
-		memcpy(*tlvs, table->tlvs, table->sizeoftlvs);
 		*sizeoftlvs = table->sizeoftlvs;
 
 		return 0;
@@ -1364,11 +1363,10 @@ static int lane2_associate_req(struct ne
 
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
 
-	priv->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
+	priv->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
 	if (priv->tlvs == NULL)
 		return (0);
 	priv->sizeoftlvs = sizeoftlvs;
-	memcpy(priv->tlvs, tlvs, sizeoftlvs);
 
 	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
 	if (skb == NULL)
@@ -1409,12 +1407,10 @@ #if 0				/*
 
 	kfree(entry->tlvs);
 
-	entry->tlvs = kmalloc(sizeoftlvs, GFP_KERNEL);
+	entry->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
 	if (entry->tlvs == NULL)
 		return;
-
 	entry->sizeoftlvs = sizeoftlvs;
-	memcpy(entry->tlvs, tlvs, sizeoftlvs);
 #endif
 #if 0
 	printk("lec.c: lane2_associate_ind()\n");
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index f15f5d8..c18f737 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -1322,13 +1322,12 @@ static void set_mps_mac_addr_rcvd(struct
 	if(client->number_of_mps_macs)
 		kfree(client->mps_macs);
 	client->number_of_mps_macs = 0;
-	client->mps_macs = kmalloc(ETH_ALEN,GFP_KERNEL);
+	client->mps_macs = kmemdup(msg->MPS_ctrl, ETH_ALEN, GFP_KERNEL);
 	if (client->mps_macs == NULL) {
 		printk("mpoa: set_mps_mac_addr_rcvd: out of memory\n");
 		return;
 	}
 	client->number_of_mps_macs = 1;
-	memcpy(client->mps_macs, msg->MPS_ctrl, ETH_ALEN);
 	
 	return;
 }
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index f3b99b3..697a081 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -87,7 +87,7 @@ static in_cache_entry *in_cache_get_by_v
 static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 					  struct mpoa_client *client)
 {
-	in_cache_entry* entry = kmalloc(sizeof(in_cache_entry), GFP_KERNEL);
+	in_cache_entry *entry = kzalloc(sizeof(in_cache_entry), GFP_KERNEL);
 
 	if (entry == NULL) {
 		printk("mpoa: mpoa_caches.c: new_in_cache_entry: out of memory\n");
@@ -95,7 +95,6 @@ static in_cache_entry *in_cache_add_entr
 	}
 
 	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %u.%u.%u.%u\n", NIPQUAD(dst_ip));
-	memset(entry,0,sizeof(in_cache_entry));
 
 	atomic_set(&entry->use, 1);
 	dprintk("mpoa: mpoa_caches.c: new_in_cache_entry: about to lock\n");
@@ -447,7 +446,7 @@ static void eg_cache_remove_entry(eg_cac
 
 static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_client *client)
 {
-	eg_cache_entry *entry = kmalloc(sizeof(eg_cache_entry), GFP_KERNEL);
+	eg_cache_entry *entry = kzalloc(sizeof(eg_cache_entry), GFP_KERNEL);
 
 	if (entry == NULL) {
 		printk("mpoa: mpoa_caches.c: new_eg_cache_entry: out of memory\n");
@@ -455,7 +454,6 @@ static eg_cache_entry *eg_cache_add_entr
 	}
 
 	dprintk("mpoa: mpoa_caches.c: adding an egress entry, ip = %u.%u.%u.%u, this should be our IP\n", NIPQUAD(msg->content.eg_info.eg_dst_ip));
-	memset(entry, 0, sizeof(eg_cache_entry));
 
 	atomic_set(&entry->use, 1);
 	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry: about to lock\n");
-- 
1.4.2.1.g3d5c

