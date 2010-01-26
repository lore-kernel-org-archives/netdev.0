From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/21] net/atm/mpoa_caches.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:10 -0800
Message-ID: <717d062fa80f8069e48eadcf958cedd4cdb5558a.1264541549.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1475 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753935Ab0AZVkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:24 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert #include <asm... to #include <linux...
Add printk argument verification to dprintk and ddprintk
Spacing cleanups
Mostly 80 column wrapped.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/mpoa_caches.c |  160 +++++++++++++++++++++++++++----------------------
 1 files changed, 88 insertions(+), 72 deletions(-)

diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 4504a4b..de21cc6 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -11,15 +11,17 @@
  */
 
 #if 0
-#define dprintk printk    /* debug */
+#define dprintk(format, args...) printk(KERN_DEBUG format, ##args)  /* debug */
 #else
-#define dprintk(format,args...)
+#define dprintk(format, args...)			\
+	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
 #endif
 
 #if 0
-#define ddprintk printk  /* more debug */
+#define ddprintk printk(KERN_DEBUG format, ##args)  /* more debug */
 #else
-#define ddprintk(format,args...)
+#define ddprintk(format, args...)			\
+	do { if (0) printk(KERN_DEBUG format, ##args); } while (0)
 #endif
 
 static in_cache_entry *in_cache_get(__be32 dst_ip,
@@ -29,8 +31,8 @@ static in_cache_entry *in_cache_get(__be32 dst_ip,
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while(entry != NULL){
-		if( entry->ctrl_info.in_dst_ip == dst_ip ){
+	while (entry != NULL) {
+		if (entry->ctrl_info.in_dst_ip == dst_ip) {
 			atomic_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
@@ -50,8 +52,8 @@ static in_cache_entry *in_cache_get_with_mask(__be32 dst_ip,
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while(entry != NULL){
-		if((entry->ctrl_info.in_dst_ip & mask)  == (dst_ip & mask )){
+	while (entry != NULL) {
+		if ((entry->ctrl_info.in_dst_ip & mask) == (dst_ip & mask)) {
 			atomic_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
@@ -65,14 +67,14 @@ static in_cache_entry *in_cache_get_with_mask(__be32 dst_ip,
 }
 
 static in_cache_entry *in_cache_get_by_vcc(struct atm_vcc *vcc,
-					   struct mpoa_client *client )
+					   struct mpoa_client *client)
 {
 	in_cache_entry *entry;
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while(entry != NULL){
-		if(entry->shortcut == vcc) {
+	while (entry != NULL) {
+		if (entry->shortcut == vcc) {
 			atomic_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
 			return entry;
@@ -90,11 +92,12 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 	in_cache_entry *entry = kzalloc(sizeof(in_cache_entry), GFP_KERNEL);
 
 	if (entry == NULL) {
-		printk("mpoa: mpoa_caches.c: new_in_cache_entry: out of memory\n");
+		pr_info("mpoa: mpoa_caches.c: new_in_cache_entry: out of memory\n");
 		return NULL;
 	}
 
-	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %pI4\n", &dst_ip);
+	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %pI4\n",
+		&dst_ip);
 
 	atomic_set(&entry->use, 1);
 	dprintk("mpoa: mpoa_caches.c: new_in_cache_entry: about to lock\n");
@@ -126,39 +129,41 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 	struct k_message msg;
 
 	entry->count++;
-	if(entry->entry_state == INGRESS_RESOLVED && entry->shortcut != NULL)
+	if (entry->entry_state == INGRESS_RESOLVED && entry->shortcut != NULL)
 		return OPEN;
 
-	if(entry->entry_state == INGRESS_REFRESHING){
-		if(entry->count > mpc->parameters.mpc_p1){
+	if (entry->entry_state == INGRESS_REFRESHING) {
+		if (entry->count > mpc->parameters.mpc_p1) {
 			msg.type = SND_MPOA_RES_RQST;
 			msg.content.in_info = entry->ctrl_info;
 			memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN);
 			qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-			if (qos != NULL) msg.qos = qos->qos;
+			if (qos != NULL)
+				msg.qos = qos->qos;
 			msg_to_mpoad(&msg, mpc);
 			do_gettimeofday(&(entry->reply_wait));
 			entry->entry_state = INGRESS_RESOLVING;
 		}
-		if(entry->shortcut != NULL)
+		if (entry->shortcut != NULL)
 			return OPEN;
 		return CLOSED;
 	}
 
-	if(entry->entry_state == INGRESS_RESOLVING && entry->shortcut != NULL)
+	if (entry->entry_state == INGRESS_RESOLVING && entry->shortcut != NULL)
 		return OPEN;
 
-	if( entry->count > mpc->parameters.mpc_p1 &&
-	    entry->entry_state == INGRESS_INVALID){
+	if (entry->count > mpc->parameters.mpc_p1 &&
+	    entry->entry_state == INGRESS_INVALID) {
 		dprintk("mpoa: (%s) mpoa_caches.c: threshold exceeded for ip %pI4, sending MPOA res req\n",
 			mpc->dev->name, &entry->ctrl_info.in_dst_ip);
 		entry->entry_state = INGRESS_RESOLVING;
-		msg.type =  SND_MPOA_RES_RQST;
-		memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN );
+		msg.type = SND_MPOA_RES_RQST;
+		memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN);
 		msg.content.in_info = entry->ctrl_info;
 		qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-		if (qos != NULL) msg.qos = qos->qos;
-		msg_to_mpoad( &msg, mpc);
+		if (qos != NULL)
+			msg.qos = qos->qos;
+		msg_to_mpoad(&msg, mpc);
 		do_gettimeofday(&(entry->reply_wait));
 	}
 
@@ -195,14 +200,15 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 	if (entry->next != NULL)
 		entry->next->prev = entry->prev;
 	client->in_ops->put(entry);
-	if(client->in_cache == NULL && client->eg_cache == NULL){
+	if (client->in_cache == NULL && client->eg_cache == NULL) {
 		msg.type = STOP_KEEP_ALIVE_SM;
-		msg_to_mpoad(&msg,client);
+		msg_to_mpoad(&msg, client);
 	}
 
 	/* Check if the egress side still uses this VCC */
 	if (vcc != NULL) {
-		eg_cache_entry *eg_entry = client->eg_ops->get_by_vcc(vcc, client);
+		eg_cache_entry *eg_entry = client->eg_ops->get_by_vcc(vcc,
+								      client);
 		if (eg_entry != NULL) {
 			client->eg_ops->put(eg_entry);
 			return;
@@ -213,7 +219,6 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 	return;
 }
 
-
 /* Call this every MPC-p2 seconds... Not exactly correct solution,
    but an easy one... */
 static void clear_count_and_expired(struct mpoa_client *client)
@@ -225,11 +230,11 @@ static void clear_count_and_expired(struct mpoa_client *client)
 
 	write_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while(entry != NULL){
-		entry->count=0;
+	while (entry != NULL) {
+		entry->count = 0;
 		next_entry = entry->next;
-		if((now.tv_sec - entry->tv.tv_sec)
-		   > entry->ctrl_info.holding_time){
+		if ((now.tv_sec - entry->tv.tv_sec)
+		   > entry->ctrl_info.holding_time) {
 			dprintk("mpoa: mpoa_caches.c: holding time expired, ip = %pI4\n",
 				&entry->ctrl_info.in_dst_ip);
 			client->in_ops->remove_entry(entry, client);
@@ -250,33 +255,38 @@ static void check_resolving_entries(struct mpoa_client *client)
 	struct timeval now;
 	struct k_message msg;
 
-	do_gettimeofday( &now );
+	do_gettimeofday(&now);
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while( entry != NULL ){
-		if(entry->entry_state == INGRESS_RESOLVING){
-			if(now.tv_sec - entry->hold_down.tv_sec < client->parameters.mpc_p6){
-				entry = entry->next;                      /* Entry in hold down */
+	while (entry != NULL) {
+		if (entry->entry_state == INGRESS_RESOLVING) {
+			if ((now.tv_sec - entry->hold_down.tv_sec) <
+			    client->parameters.mpc_p6) {
+				entry = entry->next;	/* Entry in hold down */
 				continue;
 			}
-			if( (now.tv_sec - entry->reply_wait.tv_sec) >
-			    entry->retry_time ){
-				entry->retry_time = MPC_C1*( entry->retry_time );
-				if(entry->retry_time > client->parameters.mpc_p5){
-					/* Retry time maximum exceeded, put entry in hold down. */
+			if ((now.tv_sec - entry->reply_wait.tv_sec) >
+			    entry->retry_time) {
+				entry->retry_time = MPC_C1 * (entry->retry_time);
+				/*
+				 * Retry time maximum exceeded,
+				 * put entry in hold down.
+				 */
+				if (entry->retry_time > client->parameters.mpc_p5) {
 					do_gettimeofday(&(entry->hold_down));
 					entry->retry_time = client->parameters.mpc_p4;
 					entry = entry->next;
 					continue;
 				}
 				/* Ask daemon to send a resolution request. */
-				memset(&(entry->hold_down),0,sizeof(struct timeval));
+				memset(&(entry->hold_down), 0, sizeof(struct timeval));
 				msg.type = SND_MPOA_RES_RTRY;
 				memcpy(msg.MPS_ctrl, client->mps_ctrl_addr, ATM_ESA_LEN);
 				msg.content.in_info = entry->ctrl_info;
 				qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-				if (qos != NULL) msg.qos = qos->qos;
+				if (qos != NULL)
+					msg.qos = qos->qos;
 				msg_to_mpoad(&msg, client);
 				do_gettimeofday(&(entry->reply_wait));
 			}
@@ -296,11 +306,12 @@ static void refresh_entries(struct mpoa_client *client)
 	do_gettimeofday(&now);
 
 	read_lock_bh(&client->ingress_lock);
-	while( entry != NULL ){
-		if( entry->entry_state == INGRESS_RESOLVED ){
-			if(!(entry->refresh_time))
-				entry->refresh_time = (2*(entry->ctrl_info.holding_time))/3;
-			if( (now.tv_sec - entry->reply_wait.tv_sec) > entry->refresh_time ){
+	while (entry != NULL) {
+		if (entry->entry_state == INGRESS_RESOLVED) {
+			if (!(entry->refresh_time))
+				entry->refresh_time = (2 * (entry->ctrl_info.holding_time))/3;
+			if ((now.tv_sec - entry->reply_wait.tv_sec) >
+			    entry->refresh_time) {
 				dprintk("mpoa: mpoa_caches.c: refreshing an entry.\n");
 				entry->entry_state = INGRESS_REFRESHING;
 
@@ -314,21 +325,22 @@ static void refresh_entries(struct mpoa_client *client)
 static void in_destroy_cache(struct mpoa_client *mpc)
 {
 	write_lock_irq(&mpc->ingress_lock);
-	while(mpc->in_cache != NULL)
+	while (mpc->in_cache != NULL)
 		mpc->in_ops->remove_entry(mpc->in_cache, mpc);
 	write_unlock_irq(&mpc->ingress_lock);
 
 	return;
 }
 
-static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id, struct mpoa_client *mpc)
+static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id,
+						struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while(entry != NULL){
-		if(entry->ctrl_info.cache_id == cache_id){
+	while (entry != NULL) {
+		if (entry->ctrl_info.cache_id == cache_id) {
 			atomic_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
 			return entry;
@@ -348,7 +360,7 @@ static eg_cache_entry *eg_cache_get_by_tag(__be32 tag, struct mpoa_client *mpc)
 
 	read_lock_irqsave(&mpc->egress_lock, flags);
 	entry = mpc->eg_cache;
-	while (entry != NULL){
+	while (entry != NULL) {
 		if (entry->ctrl_info.tag == tag) {
 			atomic_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
@@ -362,14 +374,15 @@ static eg_cache_entry *eg_cache_get_by_tag(__be32 tag, struct mpoa_client *mpc)
 }
 
 /* This can be called from any context since it saves CPU flags */
-static eg_cache_entry *eg_cache_get_by_vcc(struct atm_vcc *vcc, struct mpoa_client *mpc)
+static eg_cache_entry *eg_cache_get_by_vcc(struct atm_vcc *vcc,
+					   struct mpoa_client *mpc)
 {
 	unsigned long flags;
 	eg_cache_entry *entry;
 
 	read_lock_irqsave(&mpc->egress_lock, flags);
 	entry = mpc->eg_cache;
-	while (entry != NULL){
+	while (entry != NULL) {
 		if (entry->shortcut == vcc) {
 			atomic_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
@@ -382,14 +395,15 @@ static eg_cache_entry *eg_cache_get_by_vcc(struct atm_vcc *vcc, struct mpoa_clie
 	return NULL;
 }
 
-static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr, struct mpoa_client *mpc)
+static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr,
+					      struct mpoa_client *mpc)
 {
 	eg_cache_entry *entry;
 
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while(entry != NULL){
-		if(entry->latest_ip_addr == ipaddr) {
+	while (entry != NULL) {
+		if (entry->latest_ip_addr == ipaddr) {
 			atomic_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
 			return entry;
@@ -429,9 +443,9 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 	if (entry->next != NULL)
 		entry->next->prev = entry->prev;
 	client->eg_ops->put(entry);
-	if(client->in_cache == NULL && client->eg_cache == NULL){
+	if (client->in_cache == NULL && client->eg_cache == NULL) {
 		msg.type = STOP_KEEP_ALIVE_SM;
-		msg_to_mpoad(&msg,client);
+		msg_to_mpoad(&msg, client);
 	}
 
 	/* Check if the ingress side still uses this VCC */
@@ -447,12 +461,13 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 	return;
 }
 
-static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_client *client)
+static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
+					  struct mpoa_client *client)
 {
 	eg_cache_entry *entry = kzalloc(sizeof(eg_cache_entry), GFP_KERNEL);
 
 	if (entry == NULL) {
-		printk("mpoa: mpoa_caches.c: new_eg_cache_entry: out of memory\n");
+		pr_info("out of memory\n");
 		return NULL;
 	}
 
@@ -472,7 +487,8 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_cli
 	entry->ctrl_info = msg->content.eg_info;
 	do_gettimeofday(&(entry->tv));
 	entry->entry_state = EGRESS_RESOLVED;
-	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry cache_id %lu\n", ntohl(entry->ctrl_info.cache_id));
+	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry cache_id %u\n",
+		ntohl(entry->ctrl_info.cache_id));
 	dprintk("mpoa: mpoa_caches.c: mps_ip = %pI4\n",
 		&entry->ctrl_info.mps_ip);
 	atomic_inc(&entry->use);
@@ -483,7 +499,7 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_cli
 	return entry;
 }
 
-static void update_eg_cache_entry(eg_cache_entry * entry, uint16_t holding_time)
+static void update_eg_cache_entry(eg_cache_entry *entry, uint16_t holding_time)
 {
 	do_gettimeofday(&(entry->tv));
 	entry->entry_state = EGRESS_RESOLVED;
@@ -502,13 +518,14 @@ static void clear_expired(struct mpoa_client *client)
 
 	write_lock_irq(&client->egress_lock);
 	entry = client->eg_cache;
-	while(entry != NULL){
+	while (entry != NULL) {
 		next_entry = entry->next;
-		if((now.tv_sec - entry->tv.tv_sec)
-		   > entry->ctrl_info.holding_time){
+		if ((now.tv_sec - entry->tv.tv_sec)
+		   > entry->ctrl_info.holding_time) {
 			msg.type = SND_EGRESS_PURGE;
 			msg.content.eg_info = entry->ctrl_info;
-			dprintk("mpoa: mpoa_caches.c: egress_cache: holding time expired, cache_id = %lu.\n",ntohl(entry->ctrl_info.cache_id));
+			dprintk("mpoa: mpoa_caches.c: egress_cache: holding time expired, cache_id = %u.\n",
+				ntohl(entry->ctrl_info.cache_id));
 			msg_to_mpoad(&msg, client);
 			client->eg_ops->remove_entry(entry, client);
 		}
@@ -522,7 +539,7 @@ static void clear_expired(struct mpoa_client *client)
 static void eg_destroy_cache(struct mpoa_client *mpc)
 {
 	write_lock_irq(&mpc->egress_lock);
-	while(mpc->eg_cache != NULL)
+	while (mpc->eg_cache != NULL)
 		mpc->eg_ops->remove_entry(mpc->eg_cache, mpc);
 	write_unlock_irq(&mpc->egress_lock);
 
@@ -530,7 +547,6 @@ static void eg_destroy_cache(struct mpoa_client *mpc)
 }
 
 
-
 static struct in_cache_ops ingress_ops = {
 	in_cache_add_entry,               /* add_entry       */
 	in_cache_get,                     /* get             */
-- 
1.6.6.rc0.57.gad7a

