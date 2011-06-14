From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] net: Remove casts of void *
Date: Mon, 13 Jun 2011 19:21:26 -0700
Message-ID: <d010144f11f9165670ac0c9e3559bf5e3191ff28.1308017857.git.joe@perches.com>
References: <cover.1308017857.git.joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Sage Weil <sage@newdream.net>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Moore <paul.moore@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308017857.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unnecessary casts of void * clutter the code.

These are the remainder casts after several specific
patches to remove netdev_priv and dev_priv.

Done via coccinelle script:

$ cat cast_void_pointer.cocci
@@
type T;
T *pt;
void *pv;
@@

- pt = (T *)pv;
+ pt = pv;

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlanproc.c                |    2 +-
 net/atm/mpc.c                       |    2 +-
 net/ceph/crypto.c                   |    2 +-
 net/decnet/dn_dev.c                 |    2 +-
 net/irda/af_irda.c                  |    4 ++--
 net/irda/ircomm/ircomm_tty_attach.c |    2 +-
 net/irda/irda_device.c              |    2 +-
 net/irda/iriap.c                    |    8 ++++----
 net/irda/irlan/irlan_client.c       |   10 +++++-----
 net/irda/irlan/irlan_common.c       |   10 +++++-----
 net/irda/irlan/irlan_eth.c          |    2 +-
 net/irda/irlan/irlan_provider.c     |   10 +++++-----
 net/irda/irqueue.c                  |    4 ++--
 net/irda/irttp.c                    |   18 +++++++++---------
 net/key/af_key.c                    |   20 ++++++++++----------
 net/netlabel/netlabel_unlabeled.c   |   10 ++++------
 net/sctp/bind_addr.c                |    2 +-
 net/sctp/input.c                    |    3 +--
 net/sctp/sm_make_chunk.c            |   26 ++++++++++----------------
 net/sctp/sm_sideeffect.c            |    2 +-
 net/sctp/socket.c                   |   16 ++++++++--------
 21 files changed, 74 insertions(+), 83 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 016d7f4..d34b6da 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -231,7 +231,7 @@ static void *vlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	++*pos;
 
-	dev = (struct net_device *)v;
+	dev = v;
 	if (v == SEQ_START_TOKEN)
 		dev = net_device_entry(&net->dev_base_head);
 
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 3ccca42..aa97240 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -1005,7 +1005,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 	struct mpoa_client *mpc;
 	struct lec_priv *priv;
 
-	dev = (struct net_device *)dev_ptr;
+	dev = dev_ptr;
 
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
index 5a8009c..85f3bc0 100644
--- a/net/ceph/crypto.c
+++ b/net/ceph/crypto.c
@@ -444,7 +444,7 @@ int ceph_key_instantiate(struct key *key, const void *data, size_t datalen)
 		goto err;
 
 	/* TODO ceph_crypto_key_decode should really take const input */
-	p = (void*)data;
+	p = (void *)data;
 	ret = ceph_crypto_key_decode(ckey, &p, (char*)data+datalen);
 	if (ret < 0)
 		goto err_ckey;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 3780fd6..48530b4 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1313,7 +1313,7 @@ static void *dn_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	++*pos;
 
-	dev = (struct net_device *)v;
+	dev = v;
 	if (v == SEQ_START_TOKEN)
 		dev = net_device_entry(&init_net.dev_base_head);
 
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index cc61697..c24f25a 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -369,7 +369,7 @@ static void irda_getvalue_confirm(int result, __u16 obj_id,
 {
 	struct irda_sock *self;
 
-	self = (struct irda_sock *) priv;
+	self = priv;
 	if (!self) {
 		IRDA_WARNING("%s: lost myself!\n", __func__);
 		return;
@@ -418,7 +418,7 @@ static void irda_selective_discovery_indication(discinfo_t *discovery,
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	self = (struct irda_sock *) priv;
+	self = priv;
 	if (!self) {
 		IRDA_WARNING("%s: lost myself!\n", __func__);
 		return;
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 3c17540..b65d66e 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -382,7 +382,7 @@ static void ircomm_tty_discovery_indication(discinfo_t *discovery,
 	info.daddr = discovery->daddr;
 	info.saddr = discovery->saddr;
 
-	self = (struct ircomm_tty_cb *) priv;
+	self = priv;
 	ircomm_tty_do_event(self, IRCOMM_TTY_DISCOVERY_INDICATION,
 			    NULL, &info);
 }
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 25cc2e6..3eca35f 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -262,7 +262,7 @@ static void irda_task_timer_expired(void *data)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	task = (struct irda_task *) data;
+	task = data;
 
 	irda_task_kick(task);
 }
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 3647753..dfc7b47 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -300,7 +300,7 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s(), reason=%s\n", __func__, irlmp_reasons[reason]);
 
-	self = (struct iriap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -754,7 +754,7 @@ static void iriap_connect_confirm(void *instance, void *sap,
 {
 	struct iriap_cb *self;
 
-	self = (struct iriap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
@@ -786,7 +786,7 @@ static void iriap_connect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
-	self = (struct iriap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(skb != NULL, return;);
 	IRDA_ASSERT(self != NULL, goto out;);
@@ -834,7 +834,7 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
-	self = (struct iriap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(skb != NULL, return 0;);
 	IRDA_ASSERT(self != NULL, goto out;);
diff --git a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
index 7ed3af9..ba1a3fc 100644
--- a/net/irda/irlan/irlan_client.c
+++ b/net/irda/irlan/irlan_client.c
@@ -198,7 +198,7 @@ static int irlan_client_ctrl_data_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
-	self = (struct irlan_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -226,8 +226,8 @@ static void irlan_client_ctrl_disconnect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
 
-	self = (struct irlan_cb *) instance;
-	tsap = (struct tsap_cb *) sap;
+	self = instance;
+	tsap = sap;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -298,7 +298,7 @@ static void irlan_client_ctrl_connect_confirm(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s()\n", __func__ );
 
-	self = (struct irlan_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -542,7 +542,7 @@ void irlan_client_get_value_confirm(int result, __u16 obj_id,
 
 	IRDA_ASSERT(priv != NULL, return;);
 
-	self = (struct irlan_cb *) priv;
+	self = priv;
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
 
 	/* We probably don't need to make any more queries */
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 6130f9d..7791176 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -317,8 +317,8 @@ static void irlan_connect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(2, "%s()\n", __func__ );
 
-	self = (struct irlan_cb *) instance;
-	tsap = (struct tsap_cb *) sap;
+	self = instance;
+	tsap = sap;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -361,7 +361,7 @@ static void irlan_connect_confirm(void *instance, void *sap,
 {
 	struct irlan_cb *self;
 
-	self = (struct irlan_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -406,8 +406,8 @@ static void irlan_disconnect_indication(void *instance,
 
 	IRDA_DEBUG(0, "%s(), reason=%d\n", __func__ , reason);
 
-	self = (struct irlan_cb *) instance;
-	tsap = (struct tsap_cb *) sap;
+	self = instance;
+	tsap = sap;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 8ee1ff6..e8d5f44 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -272,7 +272,7 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	struct irlan_cb *self;
 	struct net_device *dev;
 
-	self = (struct irlan_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
diff --git a/net/irda/irlan/irlan_provider.c b/net/irda/irlan/irlan_provider.c
index b8af74a..8b61cf0 100644
--- a/net/irda/irlan/irlan_provider.c
+++ b/net/irda/irlan/irlan_provider.c
@@ -73,7 +73,7 @@ static int irlan_provider_data_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s()\n", __func__ );
 
-	self = (struct irlan_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
@@ -131,8 +131,8 @@ static void irlan_provider_connect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
-	self = (struct irlan_cb *) instance;
-	tsap = (struct tsap_cb *) sap;
+	self = instance;
+	tsap = sap;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -182,8 +182,8 @@ static void irlan_provider_disconnect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s(), reason=%d\n", __func__ , reason);
 
-	self = (struct irlan_cb *) instance;
-	tsap = (struct tsap_cb *) sap;
+	self = instance;
+	tsap = sap;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index 9715e6e..f06947c 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -780,7 +780,7 @@ void* hashbin_lock_find( hashbin_t* hashbin, long hashv, const char* name )
 	/*
 	 * Search for entry
 	 */
-	entry = (irda_queue_t* ) hashbin_find( hashbin, hashv, name );
+	entry = hashbin_find(hashbin, hashv, name);
 
 	/* Release lock */
 	spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
@@ -813,7 +813,7 @@ void* hashbin_find_next( hashbin_t* hashbin, long hashv, const char* name,
 	 * This allow to check if the current item is still in the
 	 * hashbin or has been removed.
 	 */
-	entry = (irda_queue_t* ) hashbin_find( hashbin, hashv, name );
+	entry = hashbin_find(hashbin, hashv, name);
 
 	/*
 	 * Trick hashbin_get_next() to return what we want
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 9d9af46..285ccd6 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -350,7 +350,7 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 {
 	struct tsap_cb *self;
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
@@ -879,7 +879,7 @@ static int irttp_udata_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
@@ -914,7 +914,7 @@ static int irttp_data_indication(void *instance, void *sap,
 	unsigned long flags;
 	int n;
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	n = skb->data[0] & 0x7f;     /* Extract the credits */
 
@@ -996,7 +996,7 @@ static void irttp_status_indication(void *instance,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
@@ -1025,7 +1025,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 {
 	struct tsap_cb *self;
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
@@ -1208,7 +1208,7 @@ static void irttp_connect_confirm(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
@@ -1292,13 +1292,13 @@ static void irttp_connect_indication(void *instance, void *sap,
 	__u8 plen;
 	__u8 n;
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 	IRDA_ASSERT(skb != NULL, return;);
 
-	lsap = (struct lsap_cb *) sap;
+	lsap = sap;
 
 	self->max_seg_size = max_seg_size - TTP_HEADER;
 	self->max_header_size = max_header_size+TTP_HEADER;
@@ -1602,7 +1602,7 @@ static void irttp_disconnect_indication(void *instance, void *sap,
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
-	self = (struct tsap_cb *) instance;
+	self = instance;
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8f92cf8..1e733e9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -621,7 +621,7 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct net *net, const struct
 	unsigned short family;
 	xfrm_address_t *xaddr;
 
-	sa = (const struct sadb_sa *) ext_hdrs[SADB_EXT_SA-1];
+	sa = ext_hdrs[SADB_EXT_SA - 1];
 	if (sa == NULL)
 		return NULL;
 
@@ -630,7 +630,7 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct net *net, const struct
 		return NULL;
 
 	/* sadb_address_len should be checked by caller */
-	addr = (const struct sadb_address *) ext_hdrs[SADB_EXT_ADDRESS_DST-1];
+	addr = ext_hdrs[SADB_EXT_ADDRESS_DST - 1];
 	if (addr == NULL)
 		return NULL;
 
@@ -1039,7 +1039,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	int err;
 
 
-	sa = (const struct sadb_sa *) ext_hdrs[SADB_EXT_SA-1];
+	sa = ext_hdrs[SADB_EXT_SA - 1];
 	if (!sa ||
 	    !present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]))
@@ -1078,7 +1078,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	     sa->sadb_sa_encrypt > SADB_X_CALG_MAX) ||
 	    sa->sadb_sa_encrypt > SADB_EALG_MAX)
 		return ERR_PTR(-EINVAL);
-	key = (const struct sadb_key*) ext_hdrs[SADB_EXT_KEY_AUTH-1];
+	key = ext_hdrs[SADB_EXT_KEY_AUTH - 1];
 	if (key != NULL &&
 	    sa->sadb_sa_auth != SADB_X_AALG_NULL &&
 	    ((key->sadb_key_bits+7) / 8 == 0 ||
@@ -1105,14 +1105,14 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 	if (sa->sadb_sa_flags & SADB_SAFLAGS_NOPMTUDISC)
 		x->props.flags |= XFRM_STATE_NOPMTUDISC;
 
-	lifetime = (const struct sadb_lifetime*) ext_hdrs[SADB_EXT_LIFETIME_HARD-1];
+	lifetime = ext_hdrs[SADB_EXT_LIFETIME_HARD - 1];
 	if (lifetime != NULL) {
 		x->lft.hard_packet_limit = _KEY2X(lifetime->sadb_lifetime_allocations);
 		x->lft.hard_byte_limit = _KEY2X(lifetime->sadb_lifetime_bytes);
 		x->lft.hard_add_expires_seconds = lifetime->sadb_lifetime_addtime;
 		x->lft.hard_use_expires_seconds = lifetime->sadb_lifetime_usetime;
 	}
-	lifetime = (const struct sadb_lifetime*) ext_hdrs[SADB_EXT_LIFETIME_SOFT-1];
+	lifetime = ext_hdrs[SADB_EXT_LIFETIME_SOFT - 1];
 	if (lifetime != NULL) {
 		x->lft.soft_packet_limit = _KEY2X(lifetime->sadb_lifetime_allocations);
 		x->lft.soft_byte_limit = _KEY2X(lifetime->sadb_lifetime_bytes);
@@ -1120,7 +1120,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 		x->lft.soft_use_expires_seconds = lifetime->sadb_lifetime_usetime;
 	}
 
-	sec_ctx = (const struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
@@ -1134,7 +1134,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 			goto out;
 	}
 
-	key = (const struct sadb_key*) ext_hdrs[SADB_EXT_KEY_AUTH-1];
+	key = ext_hdrs[SADB_EXT_KEY_AUTH - 1];
 	if (sa->sadb_sa_auth) {
 		int keysize = 0;
 		struct xfrm_algo_desc *a = xfrm_aalg_get_byid(sa->sadb_sa_auth);
@@ -2219,7 +2219,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	if (xp->selector.dport)
 		xp->selector.dport_mask = htons(0xffff);
 
-	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
@@ -2323,7 +2323,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 	if (sel.dport)
 		sel.dport_mask = htons(0xffff);
 
-	sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
+	sec_ctx = ext_hdrs[SADB_X_EXT_SEC_CTX - 1];
 	if (sec_ctx != NULL) {
 		struct xfrm_user_sec_ctx *uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
 
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 9c38658..8efd061 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -426,10 +426,9 @@ int netlbl_unlhsh_add(struct net *net,
 					      audit_info);
 	switch (addr_len) {
 	case sizeof(struct in_addr): {
-		struct in_addr *addr4, *mask4;
+		const struct in_addr *addr4 = addr;
+		const struct in_addr *mask4 = mask;
 
-		addr4 = (struct in_addr *)addr;
-		mask4 = (struct in_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr4(iface, addr4, mask4, secid);
 		if (audit_buf != NULL)
 			netlbl_af4list_audit_addr(audit_buf, 1,
@@ -440,10 +439,9 @@ int netlbl_unlhsh_add(struct net *net,
 	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case sizeof(struct in6_addr): {
-		struct in6_addr *addr6, *mask6;
+		const struct in6_addr *addr6 = addr;
+		const struct in6_addr *mask6 = mask;
 
-		addr6 = (struct in6_addr *)addr;
-		mask6 = (struct in6_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr6(iface, addr6, mask6, secid);
 		if (audit_buf != NULL)
 			netlbl_af6list_audit_addr(audit_buf, 1,
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 17d1573..4ece451 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -430,7 +430,7 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 	list_for_each_entry(laddr, &bp->address_list, list) {
 		addr_buf = (union sctp_addr *)addrs;
 		for (i = 0; i < addrcnt; i++) {
-			addr = (union sctp_addr *)addr_buf;
+			addr = addr_buf;
 			af = sctp_get_af_specific(addr->v4.sin_family);
 			if (!af)
 				break;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 741ed16..b7692aa 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -510,8 +510,7 @@ struct sock *sctp_err_lookup(int family, struct sk_buff *skb,
 	 * discard the packet.
 	 */
 	if (vtag == 0) {
-		chunkhdr = (struct sctp_init_chunk *)((void *)sctphdr
-				+ sizeof(struct sctphdr));
+		chunkhdr = (void *)sctphdr + sizeof(struct sctphdr);
 		if (len < sizeof(struct sctphdr) + sizeof(sctp_chunkhdr_t)
 			  + sizeof(__be32) ||
 		    chunkhdr->chunk_hdr.type != SCTP_CID_INIT ||
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3363d37..81db4e3 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2773,7 +2773,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	/* Get total length of all the address parameters. */
 	addr_buf = addrs;
 	for (i = 0; i < addrcnt; i++) {
-		addr = (union sctp_addr *)addr_buf;
+		addr = addr_buf;
 		af = sctp_get_af_specific(addr->v4.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 
@@ -2798,7 +2798,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	/* Add the address parameters to the asconf chunk. */
 	addr_buf = addrs;
 	for (i = 0; i < addrcnt; i++) {
-		addr = (union sctp_addr *)addr_buf;
+		addr = addr_buf;
 		af = sctp_get_af_specific(addr->v4.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 		param.param_hdr.type = flags;
@@ -2958,8 +2958,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	union sctp_addr	addr;
 	union sctp_addr_param *addr_param;
 
-	addr_param = (union sctp_addr_param *)
-			((void *)asconf_param + sizeof(sctp_addip_param_t));
+	addr_param = (void *)asconf_param + sizeof(sctp_addip_param_t);
 
 	if (asconf_param->param_hdr.type != SCTP_PARAM_ADD_IP &&
 	    asconf_param->param_hdr.type != SCTP_PARAM_DEL_IP &&
@@ -3144,7 +3143,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	 * asconf parameter.
 	 */
 	length = ntohs(addr_param->p.length);
-	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
+	asconf_param = (void *)addr_param + length;
 	chunk_len -= length;
 
 	/* create an ASCONF_ACK chunk.
@@ -3185,8 +3184,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 
 		/* Move to the next ASCONF param. */
 		length = ntohs(asconf_param->param_hdr.length);
-		asconf_param = (sctp_addip_param_t *)((void *)asconf_param +
-						      length);
+		asconf_param = (void *)asconf_param + length;
 		chunk_len -= length;
 	}
 
@@ -3216,8 +3214,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 	struct sctp_transport *transport;
 	struct sctp_sockaddr_entry *saddr;
 
-	addr_param = (union sctp_addr_param *)
-			((void *)asconf_param + sizeof(sctp_addip_param_t));
+	addr_param = (void *)asconf_param + sizeof(sctp_addip_param_t);
 
 	/* We have checked the packet before, so we do not check again.	*/
 	af = sctp_get_af_specific(param_type2af(addr_param->p.type));
@@ -3302,8 +3299,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 				return SCTP_ERROR_NO_ERROR;
 			case SCTP_PARAM_ERR_CAUSE:
 				length = sizeof(sctp_addip_param_t);
-				err_param = (sctp_errhdr_t *)
-					   ((void *)asconf_ack_param + length);
+				err_param = (void *)asconf_ack_param + length;
 				asconf_ack_len -= length;
 				if (asconf_ack_len > 0)
 					return err_param->cause;
@@ -3316,8 +3312,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 		}
 
 		length = ntohs(asconf_ack_param->param_hdr.length);
-		asconf_ack_param = (sctp_addip_param_t *)
-					((void *)asconf_ack_param + length);
+		asconf_ack_param = (void *)asconf_ack_param + length;
 		asconf_ack_len -= length;
 	}
 
@@ -3349,7 +3344,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	 * pointer to the first asconf parameter.
 	 */
 	length = ntohs(addr_param->p.length);
-	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
+	asconf_param = (void *)addr_param + length;
 	asconf_len -= length;
 
 	/* ADDIP 4.1
@@ -3400,8 +3395,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 		 * one.
 		 */
 		length = ntohs(asconf_param->param_hdr.length);
-		asconf_param = (sctp_addip_param_t *)((void *)asconf_param +
-						      length);
+		asconf_param = (void *)asconf_param + length;
 		asconf_len -= length;
 	}
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 534c2e5..1b2bb64 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1201,7 +1201,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 	int local_cork = 0;
 
 	if (SCTP_EVENT_T_TIMEOUT != event_type)
-		chunk = (struct sctp_chunk *) event_arg;
+		chunk = event_arg;
 
 	/* Note:  This whole file is a huge candidate for rework.
 	 * For example, each command could either have its own handler, so
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 60038fe..fd31b36 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -476,7 +476,7 @@ static int sctp_bindx_add(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 		/* The list may contain either IPv4 or IPv6 address;
 		 * determine the address length for walking thru the list.
 		 */
-		sa_addr = (struct sockaddr *)addr_buf;
+		sa_addr = addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa_family);
 		if (!af) {
 			retval = -EINVAL;
@@ -555,7 +555,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 		 */
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
-			addr = (union sctp_addr *)addr_buf;
+			addr = addr_buf;
 			af = sctp_get_af_specific(addr->v4.sin_family);
 			if (!af) {
 				retval = -EINVAL;
@@ -588,7 +588,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 		 */
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
-			addr = (union sctp_addr *)addr_buf;
+			addr = addr_buf;
 			af = sctp_get_af_specific(addr->v4.sin_family);
 			memcpy(&saveaddr, addr, af->sockaddr_len);
 			retval = sctp_add_bind_addr(bp, &saveaddr,
@@ -659,7 +659,7 @@ static int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 			goto err_bindx_rem;
 		}
 
-		sa_addr = (union sctp_addr *)addr_buf;
+		sa_addr = addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa.sa_family);
 		if (!af) {
 			retval = -EINVAL;
@@ -758,7 +758,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		 */
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
-			laddr = (union sctp_addr *)addr_buf;
+			laddr = addr_buf;
 			af = sctp_get_af_specific(laddr->v4.sin_family);
 			if (!af) {
 				retval = -EINVAL;
@@ -830,7 +830,7 @@ skip_mkasconf:
 		 */
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
-			laddr = (union sctp_addr *)addr_buf;
+			laddr = addr_buf;
 			af = sctp_get_af_specific(laddr->v4.sin_family);
 			list_for_each_entry(saddr, &bp->address_list, list) {
 				if (sctp_cmp_addr_exact(&saddr->a, laddr))
@@ -997,7 +997,7 @@ SCTP_STATIC int sctp_setsockopt_bindx(struct sock* sk,
 			return -EINVAL;
 		}
 
-		sa_addr = (struct sockaddr *)addr_buf;
+		sa_addr = addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa_family);
 
 		/* If the address family is not supported or if this address
@@ -1088,7 +1088,7 @@ static int __sctp_connect(struct sock* sk,
 			goto out_free;
 		}
 
-		sa_addr = (union sctp_addr *)addr_buf;
+		sa_addr = addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa.sa_family);
 
 		/* If the address family is not supported or if this address
-- 
1.7.6.rc0
