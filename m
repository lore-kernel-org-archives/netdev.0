From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] net/atm: Adjust 121 checks for null pointers
Date: Mon, 9 Oct 2017 22:52:22 +0200
Message-ID: <bdd41a34-143a-b075-dca8-e43199abdbd1@users.sourceforge.net>
References: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Bhumika Goyal <bhumirks@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Windsor <dwindsor@gmail.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kees Cook <keescook@chromium.org>,
        Mitchell Blank Jr <mitch@sfgoth.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10a92558-1105-b947-86a2-6ac763cca36d@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 9 Oct 2017 22:22:45 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/br2684.c      |  17 ++++----
 net/atm/clip.c        |   2 +-
 net/atm/lec.c         |  38 ++++++++---------
 net/atm/mpc.c         | 114 +++++++++++++++++++++++++-------------------------
 net/atm/mpoa_caches.c |  63 ++++++++++++++--------------
 net/atm/pppoatm.c     |  11 +++--
 net/atm/proc.c        |   2 +-
 7 files changed, 123 insertions(+), 124 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index f5b601c01f38..d3f8ec90556a 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -212,7 +212,7 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, minheadroom);
 		brvcc->copies_needed++;
 		dev_kfree_skb(skb);
-		if (skb2 == NULL) {
+		if (!skb2) {
 			brvcc->copies_failed++;
 			return 0;
 		}
@@ -299,7 +299,7 @@ static netdev_tx_t br2684_start_xmit(struct sk_buff *skb,
 	pr_debug("skb_dst(skb)=%p\n", skb_dst(skb));
 	read_lock(&devs_lock);
 	brvcc = pick_outgoing_vcc(skb, brdev);
-	if (brvcc == NULL) {
+	if (!brvcc) {
 		pr_debug("no vcc attached to dev %s\n", dev->name);
 		dev->stats.tx_errors++;
 		dev->stats.tx_carrier_errors++;
@@ -372,13 +372,13 @@ static int br2684_setfilt(struct atm_vcc *atmvcc, void __user * arg)
 		struct br2684_dev *brdev;
 		read_lock(&devs_lock);
 		brdev = BRPRIV(br2684_find_dev(&fs.ifspec));
-		if (brdev == NULL || list_empty(&brdev->brvccs) ||
+		if (!brdev || list_empty(&brdev->brvccs) ||
 		    brdev->brvccs.next != brdev->brvccs.prev)	/* >1 VCC */
 			brvcc = NULL;
 		else
 			brvcc = list_entry_brvcc(brdev->brvccs.next);
 		read_unlock(&devs_lock);
-		if (brvcc == NULL)
+		if (!brvcc)
 			return -ESRCH;
 	} else
 		brvcc = BR2684_VCC(atmvcc);
@@ -427,8 +427,7 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	struct br2684_dev *brdev = BRPRIV(net_dev);
 
 	pr_debug("\n");
-
-	if (unlikely(skb == NULL)) {
+	if (unlikely(!skb)) {
 		/* skb==NULL means VCC is being destroyed */
 		br2684_close_vcc(brvcc);
 		if (list_empty(&brdev->brvccs)) {
@@ -550,13 +549,13 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	atomic_set(&brvcc->qspace, 2);
 	write_lock_irq(&devs_lock);
 	net_dev = br2684_find_dev(&be.ifspec);
-	if (net_dev == NULL) {
+	if (!net_dev) {
 		pr_err("tried to attach to non-existent device\n");
 		err = -ENXIO;
 		goto error;
 	}
 	brdev = BRPRIV(net_dev);
-	if (atmvcc->push == NULL) {
+	if (!atmvcc->push) {
 		err = -EBADFD;
 		goto error;
 	}
@@ -839,7 +838,7 @@ static int __init br2684_init(void)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
 	p = proc_create("br2684", 0, atm_proc_root, &br2684_proc_ops);
-	if (p == NULL)
+	if (!p)
 		return -ENOMEM;
 #endif
 	register_atm_ioctl(&br2684_ioctl_ops);
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 041d519b8771..b45bfcb6cc1b 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -809,7 +809,7 @@ static void *clip_seq_vcc_walk(struct clip_seq_state *state,
 	struct clip_vcc *vcc = state->vcc;
 
 	vcc = clip_seq_next_vcc(e, vcc);
-	if (vcc && pos != NULL) {
+	if (vcc && pos) {
 		while (*pos) {
 			vcc = clip_seq_next_vcc(e, vcc);
 			if (!vcc)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 74a794602412..4f94c6ed893c 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -139,7 +139,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		struct atmlec_msg *mesg;
 
 		skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-		if (skb2 == NULL)
+		if (!skb2)
 			return;
 		skb2->len = sizeof(struct atmlec_msg);
 		mesg = (struct atmlec_msg *)skb2->data;
@@ -264,7 +264,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 					       min_frame_size - skb->truesize,
 					       GFP_ATOMIC);
 			dev_kfree_skb(skb);
-			if (skb2 == NULL) {
+			if (!skb2) {
 				dev->stats.tx_dropped++;
 				return NETDEV_TX_OK;
 			}
@@ -431,7 +431,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		pr_debug("%s: bridge zeppelin asks about %pM\n",
 			 dev->name, mesg->content.proxy.mac_addr);
 
-		if (br_fdb_test_addr_hook == NULL)
+		if (!br_fdb_test_addr_hook)
 			break;
 
 		if (br_fdb_test_addr_hook(dev, mesg->content.proxy.mac_addr)) {
@@ -442,7 +442,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			pr_debug("%s: entry found, responding to zeppelin\n",
 				 dev->name);
 			skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-			if (skb2 == NULL)
+			if (!skb2)
 				break;
 			skb2->len = sizeof(struct atmlec_msg);
 			skb_copy_to_linear_data(skb2, mesg, sizeof(*mesg));
@@ -520,7 +520,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	mesg = (struct atmlec_msg *)skb->data;
 	memset(mesg, 0, sizeof(struct atmlec_msg));
 	mesg->type = type;
-	if (data != NULL)
+	if (data)
 		mesg->sizeoftlvs = data->len;
 	if (mac_addr)
 		ether_addr_copy(mesg->content.normal.mac_addr, mac_addr);
@@ -534,7 +534,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk);
 
-	if (data != NULL) {
+	if (data) {
 		pr_debug("about to send %d bytes of data\n", data->len);
 		atm_force_charge(priv->lecd, data->truesize);
 		skb_queue_tail(&sk->sk_receive_queue, data);
@@ -663,7 +663,7 @@ static void lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
 	struct net_device *dev = skb->dev;
 
-	if (vpriv == NULL) {
+	if (!vpriv) {
 		pr_info("vpriv = NULL!?!?!?\n");
 		return;
 	}
@@ -1066,7 +1066,7 @@ static void __exit lane_module_cleanup(void)
 	deregister_atm_ioctl(&lane_ioctl_ops);
 
 	for (i = 0; i < MAX_LEC_ITF; i++) {
-		if (dev_lec[i] != NULL) {
+		if (dev_lec[i]) {
 			unregister_netdev(dev_lec[i]);
 			free_netdev(dev_lec[i]);
 			dev_lec[i] = NULL;
@@ -1097,11 +1097,11 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
 		table = lec_arp_find(priv, dst_mac);
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-		if (table == NULL)
+		if (!table)
 			return -1;
 
 		*tlvs = kmemdup(table->tlvs, table->sizeoftlvs, GFP_ATOMIC);
-		if (*tlvs == NULL)
+		if (!*tlvs)
 			return -1;
 
 		*sizeoftlvs = table->sizeoftlvs;
@@ -1109,12 +1109,12 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 		return 0;
 	}
 
-	if (sizeoftlvs == NULL)
+	if (!sizeoftlvs)
 		retval = send_to_lecd(priv, l_arp_xmt, dst_mac, NULL, NULL);
 
 	else {
 		skb = alloc_skb(*sizeoftlvs, GFP_ATOMIC);
-		if (skb == NULL)
+		if (!skb)
 			return -1;
 		skb->len = *sizeoftlvs;
 		skb_copy_to_linear_data(skb, *tlvs, *sizeoftlvs);
@@ -1143,12 +1143,12 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
 
 	priv->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
-	if (priv->tlvs == NULL)
+	if (!priv->tlvs)
 		return 0;
 	priv->sizeoftlvs = sizeoftlvs;
 
 	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return 0;
 	skb->len = sizeoftlvs;
 	skb_copy_to_linear_data(skb, tlvs, sizeoftlvs);
@@ -1181,13 +1181,13 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 				 */
 	struct lec_arp_table *entry = lec_arp_find(priv, mac_addr);
 
-	if (entry == NULL)
+	if (!entry)
 		return;		/* should not happen */
 
 	kfree(entry->tlvs);
 
 	entry->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
-	if (entry->tlvs == NULL)
+	if (!entry->tlvs)
 		return;
 	entry->sizeoftlvs = sizeoftlvs;
 #endif
@@ -1854,7 +1854,7 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	entry = lec_arp_find(priv, mac_addr);
-	if (entry == NULL && targetless_le_arp)
+	if (!entry && targetless_le_arp)
 		goto out;	/*
 				 * LANE2: ignore targetless LE_ARPs for which
 				 * we have no entry in the cache. 7.1.30
@@ -1965,7 +1965,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		entry->old_recv_push = old_push;
 #endif
 		entry = make_entry(priv, bus_mac);
-		if (entry == NULL)
+		if (!entry)
 			goto out;
 		del_timer(&entry->timer);
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -1990,7 +1990,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 			 ioc_data->atm_addr[16], ioc_data->atm_addr[17],
 			 ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 		entry = make_entry(priv, bus_mac);
-		if (entry == NULL)
+		if (!entry)
 			goto out;
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
 		eth_zero_addr(entry->mac_addr);
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index d6729d797107..ece715f8c9f7 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -129,7 +129,7 @@ static struct mpoa_client *find_mpc_by_itfnum(int itf)
 	struct mpoa_client *mpc;
 
 	mpc = mpcs;  /* our global linked list */
-	while (mpc != NULL) {
+	while (mpc) {
 		if (mpc->dev_num == itf)
 			return mpc;
 		mpc = mpc->next;
@@ -143,7 +143,7 @@ static struct mpoa_client *find_mpc_by_vcc(struct atm_vcc *vcc)
 	struct mpoa_client *mpc;
 
 	mpc = mpcs;  /* our global linked list */
-	while (mpc != NULL) {
+	while (mpc) {
 		if (mpc->mpoad_vcc == vcc)
 			return mpc;
 		mpc = mpc->next;
@@ -157,7 +157,7 @@ static struct mpoa_client *find_mpc_by_lec(struct net_device *dev)
 	struct mpoa_client *mpc;
 
 	mpc = mpcs;  /* our global linked list */
-	while (mpc != NULL) {
+	while (mpc) {
 		if (mpc->dev == dev)
 			return mpc;
 		mpc = mpc->next;
@@ -178,7 +178,7 @@ struct atm_mpoa_qos *atm_mpoa_add_qos(__be32 dst_ip, struct atm_qos *qos)
 	struct atm_mpoa_qos *entry;
 
 	entry = atm_mpoa_search_qos(dst_ip);
-	if (entry != NULL) {
+	if (entry) {
 		entry->qos = *qos;
 		return entry;
 	}
@@ -217,7 +217,7 @@ int atm_mpoa_delete_qos(struct atm_mpoa_qos *entry)
 {
 	struct atm_mpoa_qos *curr;
 
-	if (entry == NULL)
+	if (!entry)
 		return 0;
 	if (entry == qos_head) {
 		qos_head = qos_head->next;
@@ -226,7 +226,7 @@ int atm_mpoa_delete_qos(struct atm_mpoa_qos *entry)
 	}
 
 	curr = qos_head;
-	while (curr != NULL) {
+	while (curr) {
 		if (curr->next == entry) {
 			curr->next = entry->next;
 			kfree(entry);
@@ -247,7 +247,7 @@ void atm_mpoa_disp_qos(struct seq_file *m)
 	seq_printf(m, "QoS entries for shortcuts:\n");
 	seq_printf(m, "IP address\n  TX:max_pcr pcr     min_pcr max_cdv max_sdu\n  RX:max_pcr pcr     min_pcr max_cdv max_sdu\n");
 
-	while (qos != NULL) {
+	while (qos) {
 		seq_printf(m, "%pI4\n     %-7d %-7d %-7d %-7d %-7d\n     %-7d %-7d %-7d %-7d %-7d\n",
 			   &qos->ipaddr,
 			   qos->qos.txtp.max_pcr,
@@ -280,7 +280,7 @@ static struct mpoa_client *alloc_mpc(void)
 	struct mpoa_client *mpc;
 
 	mpc = kzalloc(sizeof(*mpc), GFP_KERNEL);
-	if (mpc == NULL)
+	if (!mpc)
 		return NULL;
 	rwlock_init(&mpc->ingress_lock);
 	rwlock_init(&mpc->egress_lock);
@@ -381,7 +381,7 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 	dprintk("(%s) received TLV(s), ", dev->name);
 	dprintk("total length of all TLVs %d\n", sizeoftlvs);
 	mpc = find_mpc_by_lec(dev); /* Sampo-Fix: moved here from below */
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("(%s) no mpc\n", dev->name);
 		return;
 	}
@@ -445,7 +445,7 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 
 		tlvs = copy_macs(mpc, mac_addr, tlvs,
 				 number_of_mps_macs, mpoa_device_type);
-		if (tlvs == NULL)
+		if (!tlvs)
 			return;
 	}
 	if (end_of_tlvs - tlvs != 0)
@@ -507,9 +507,9 @@ static int send_via_shortcut(struct sk_buff *skb, struct mpoa_client *mpc)
 		 mpc->dev->name, ipaddr);
 
 	entry = mpc->in_ops->get(ipaddr, mpc);
-	if (entry == NULL) {
+	if (!entry) {
 		entry = mpc->in_ops->add_entry(ipaddr, mpc);
-		if (entry != NULL)
+		if (entry)
 			mpc->in_ops->put(entry);
 		return 1;
 	}
@@ -571,7 +571,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 	int i = 0;
 
 	mpc = find_mpc_by_lec(dev); /* this should NEVER fail */
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("(%s) no MPC found\n", dev->name);
 		goto non_ip;
 	}
@@ -617,16 +617,16 @@ static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 		return -EINVAL;
 
 	mpc = find_mpc_by_itfnum(ioc_data.dev_num);
-	if (mpc == NULL)
+	if (!mpc)
 		return -EINVAL;
 
 	if (ioc_data.type == MPC_SOCKET_INGRESS) {
 		in_entry = mpc->in_ops->get(ipaddr, mpc);
-		if (in_entry == NULL ||
+		if (!in_entry ||
 		    in_entry->entry_state < INGRESS_RESOLVED) {
 			pr_info("(%s) did not find RESOLVED entry from ingress cache\n",
 				mpc->dev->name);
-			if (in_entry != NULL)
+			if (in_entry)
 				mpc->in_ops->put(in_entry);
 			return -EINVAL;
 		}
@@ -654,7 +654,7 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 	eg_cache_entry *eg_entry;
 
 	mpc = find_mpc_by_lec(dev);
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("(%s) close for unknown MPC\n", dev->name);
 		return;
 	}
@@ -674,7 +674,7 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 		mpc->eg_ops->put(eg_entry);
 	}
 
-	if (in_entry == NULL && eg_entry == NULL)
+	if (!in_entry && !eg_entry)
 		dprintk("(%s) unused vcc closed\n", dev->name);
 }
 
@@ -688,7 +688,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	char *tmp;
 
 	ddprintk("(%s)\n", dev->name);
-	if (skb == NULL) {
+	if (!skb) {
 		dprintk("(%s) null skb, closing VCC\n", dev->name);
 		mpc_vcc_close(vcc, dev);
 		return;
@@ -710,7 +710,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	atm_return(vcc, skb->truesize);
 
 	mpc = find_mpc_by_lec(dev);
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("(%s) unknown MPC\n", dev->name);
 		return;
 	}
@@ -735,7 +735,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	tag = *(__be32 *)tmp;
 
 	eg = mpc->eg_ops->get_by_tag(tag, mpc);
-	if (eg == NULL) {
+	if (!eg) {
 		pr_info("mpoa: (%s) Didn't find egress cache entry, tag = %u\n",
 			dev->name, tag);
 		purge_egress_shortcut(vcc, NULL);
@@ -747,7 +747,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	 * See if ingress MPC is using shortcut we opened as a return channel.
 	 * This means we have a bi-directional vcc opened by us.
 	 */
-	if (eg->shortcut == NULL) {
+	if (!eg->shortcut) {
 		eg->shortcut = vcc;
 		pr_info("(%s) egress SVC in use\n", dev->name);
 	}
@@ -757,7 +757,7 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	new_skb = skb_realloc_headroom(skb, eg->ctrl_info.DH_length);
 					/* LLC/SNAP is shorter than MAC header :( */
 	dev_kfree_skb_any(skb);
-	if (new_skb == NULL) {
+	if (!new_skb) {
 		mpc->eg_ops->put(eg);
 		return;
 	}
@@ -794,7 +794,7 @@ static int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg)
 	struct lec_priv *priv;
 	int err;
 
-	if (mpcs == NULL) {
+	if (!mpcs) {
 		init_timer(&mpc_timer);
 		mpc_timer_refresh();
 
@@ -807,10 +807,10 @@ static int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg)
 	}
 
 	mpc = find_mpc_by_itfnum(arg);
-	if (mpc == NULL) {
+	if (!mpc) {
 		dprintk("allocating new mpc for itf %d\n", arg);
 		mpc = alloc_mpc();
-		if (mpc == NULL)
+		if (!mpc)
 			return -ENOMEM;
 		mpc->dev_num = arg;
 		mpc->dev = find_lec_by_itfnum(arg);
@@ -869,7 +869,7 @@ static void mpoad_close(struct atm_vcc *vcc)
 	struct sk_buff *skb;
 
 	mpc = find_mpc_by_vcc(vcc);
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("did not find MPC\n");
 		return;
 	}
@@ -909,7 +909,7 @@ static int msg_from_mpoad(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct k_message *mesg = (struct k_message *)skb->data;
 	WARN_ON(refcount_sub_and_test(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc));
 
-	if (mpc == NULL) {
+	if (!mpc) {
 		pr_info("no mpc found\n");
 		return 0;
 	}
@@ -974,13 +974,13 @@ int msg_to_mpoad(struct k_message *mesg, struct mpoa_client *mpc)
 	struct sk_buff *skb;
 	struct sock *sk;
 
-	if (mpc == NULL || !mpc->mpoad_vcc) {
+	if (!mpc || !mpc->mpoad_vcc) {
 		pr_info("mesg %d to a non-existent mpoad\n", mesg->type);
 		return -ENXIO;
 	}
 
 	skb = alloc_skb(sizeof(struct k_message), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return -ENOMEM;
 	skb_put(skb, sizeof(struct k_message));
 	skb_copy_to_linear_data(skb, mesg, sizeof(*mesg));
@@ -1013,10 +1013,10 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 			break;
 		priv->lane2_ops->associate_indicator = lane2_assoc_ind;
 		mpc = find_mpc_by_itfnum(priv->itfnum);
-		if (mpc == NULL) {
+		if (!mpc) {
 			dprintk("allocating new mpc for %s\n", dev->name);
 			mpc = alloc_mpc();
-			if (mpc == NULL) {
+			if (!mpc) {
 				pr_info("no new mpc");
 				break;
 			}
@@ -1029,7 +1029,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 	case NETDEV_UNREGISTER:
 		/* the lec device was deallocated */
 		mpc = find_mpc_by_lec(dev);
-		if (mpc == NULL)
+		if (!mpc)
 			break;
 		dprintk("device (%s) was deallocated\n", dev->name);
 		stop_mpc(mpc);
@@ -1039,9 +1039,9 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 	case NETDEV_UP:
 		/* the dev was ifconfig'ed up */
 		mpc = find_mpc_by_lec(dev);
-		if (mpc == NULL)
+		if (!mpc)
 			break;
-		if (mpc->mpoad_vcc != NULL)
+		if (mpc->mpoad_vcc)
 			start_mpc(mpc, dev);
 		break;
 	case NETDEV_DOWN:
@@ -1050,9 +1050,9 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 		 * upper layer stops
 		 */
 		mpc = find_mpc_by_lec(dev);
-		if (mpc == NULL)
+		if (!mpc)
 			break;
-		if (mpc->mpoad_vcc != NULL)
+		if (mpc->mpoad_vcc)
 			stop_mpc(mpc);
 		break;
 	case NETDEV_REBOOT:
@@ -1080,7 +1080,7 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	in_cache_entry *entry;
 
 	entry = mpc->in_ops->get(dst_ip, mpc);
-	if (entry == NULL) {
+	if (!entry) {
 		entry = mpc->in_ops->add_entry(dst_ip, mpc);
 		entry->entry_state = INGRESS_RESOLVING;
 		msg->type = SND_MPOA_RES_RQST;
@@ -1134,7 +1134,7 @@ static void check_qos_and_open_shortcut(struct k_message *msg,
 			return;
 		}
 	}
-	if (eg_entry != NULL)
+	if (eg_entry)
 		client->eg_ops->put(eg_entry);
 
 	/* No luck in the egress cache we must open an ingress SVC */
@@ -1158,7 +1158,7 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 		mpc->dev->name, &dst_ip);
 	ddprintk("(%s) entry = %p",
 		 mpc->dev->name, entry);
-	if (entry == NULL) {
+	if (!entry) {
 		pr_info("(%s) ARGH, received res. reply for an entry that doesn't exist.\n",
 			mpc->dev->name);
 		return;
@@ -1178,13 +1178,13 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	ddprintk_cont("entry->shortcut = %p\n", entry->shortcut);
 
 	if (entry->entry_state == INGRESS_RESOLVING &&
-	    entry->shortcut != NULL) {
+	    entry->shortcut) {
 		entry->entry_state = INGRESS_RESOLVED;
 		mpc->in_ops->put(entry);
 		return; /* Shortcut already open... */
 	}
 
-	if (entry->shortcut != NULL) {
+	if (entry->shortcut) {
 		pr_info("(%s) entry->shortcut != NULL, impossible!\n",
 			mpc->dev->name);
 		mpc->in_ops->put(entry);
@@ -1205,7 +1205,7 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	__be32 mask = msg->ip_mask;
 	in_cache_entry *entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
 
-	if (entry == NULL) {
+	if (!entry) {
 		pr_info("(%s) purge for a non-existing entry, ip = %pI4\n",
 			mpc->dev->name, &dst_ip);
 		return;
@@ -1219,7 +1219,7 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 		write_unlock_bh(&mpc->ingress_lock);
 		mpc->in_ops->put(entry);
 		entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
-	} while (entry != NULL);
+	} while (entry);
 }
 
 static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
@@ -1227,7 +1227,7 @@ static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	__be32 cache_id = msg->content.eg_info.cache_id;
 	eg_cache_entry *entry = mpc->eg_ops->get_by_cache_id(cache_id, mpc);
 
-	if (entry == NULL) {
+	if (!entry) {
 		dprintk("(%s) purge for a non-existing entry\n",
 			mpc->dev->name);
 		return;
@@ -1247,13 +1247,13 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	struct sk_buff *skb;
 
 	dprintk("entering\n");
-	if (vcc == NULL) {
+	if (!vcc) {
 		pr_info("vcc == NULL\n");
 		return;
 	}
 
 	skb = alloc_skb(sizeof(struct k_message), GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		pr_info("out of memory\n");
 		return;
 	}
@@ -1262,7 +1262,7 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	memset(skb->data, 0, sizeof(struct k_message));
 	purge_msg = (struct k_message *)skb->data;
 	purge_msg->type = DATA_PLANE_PURGE;
-	if (entry != NULL)
+	if (entry)
 		purge_msg->content.eg_info = entry->ctrl_info;
 
 	atm_force_charge(vcc, skb->truesize);
@@ -1291,7 +1291,7 @@ static void mps_death(struct k_message *msg, struct mpoa_client *mpc)
 	/* FIXME: This knows too much of the cache structure */
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		purge_egress_shortcut(entry->shortcut, entry);
 		entry = entry->next;
 	}
@@ -1310,7 +1310,7 @@ static void MPOA_cache_impos_rcvd(struct k_message *msg,
 	holding_time = msg->content.eg_info.holding_time;
 	dprintk("(%s) entry = %p, holding_time = %u\n",
 		mpc->dev->name, entry, holding_time);
-	if (entry == NULL && holding_time) {
+	if (!entry && holding_time) {
 		entry = mpc->eg_ops->add_entry(msg, mpc);
 		mpc->eg_ops->put(entry);
 		return;
@@ -1372,7 +1372,7 @@ static void set_mps_mac_addr_rcvd(struct k_message *msg,
 		kfree(client->mps_macs);
 	client->number_of_mps_macs = 0;
 	client->mps_macs = kmemdup(msg->MPS_ctrl, ETH_ALEN, GFP_KERNEL);
-	if (client->mps_macs == NULL) {
+	if (!client->mps_macs) {
 		pr_info("out of memory\n");
 		return;
 	}
@@ -1392,7 +1392,7 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 	/* FIXME: This knows too much of the cache structure */
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		msg->content.eg_info = entry->ctrl_info;
 		dprintk("cache_id %u\n", entry->ctrl_info.cache_id);
 		msg_to_mpoad(msg, mpc);
@@ -1418,7 +1418,7 @@ static void mpc_cache_check(unsigned long checking_time)
 	static unsigned long previous_resolving_check_time;
 	static unsigned long previous_refresh_time;
 
-	while (mpc != NULL) {
+	while (mpc) {
 		mpc->in_ops->clear_count(mpc);
 		mpc->eg_ops->clear_expired(mpc);
 		if (checking_time - previous_resolving_check_time >
@@ -1494,12 +1494,12 @@ static void __exit atm_mpoa_cleanup(void)
 
 	mpc = mpcs;
 	mpcs = NULL;
-	while (mpc != NULL) {
+	while (mpc) {
 		tmp = mpc->next;
-		if (mpc->dev != NULL) {
+		if (mpc->dev) {
 			stop_mpc(mpc);
 			priv = netdev_priv(mpc->dev);
-			if (priv->lane2_ops != NULL)
+			if (priv->lane2_ops)
 				priv->lane2_ops->associate_indicator = NULL;
 		}
 		ddprintk("about to clear caches\n");
@@ -1516,7 +1516,7 @@ static void __exit atm_mpoa_cleanup(void)
 
 	qos = qos_head;
 	qos_head = NULL;
-	while (qos != NULL) {
+	while (qos) {
 		nextqos = qos->next;
 		dprintk("freeing qos entry %p\n", qos);
 		kfree(qos);
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 23f36e5a20ee..c147fe916446 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -38,7 +38,7 @@ static in_cache_entry *in_cache_get(__be32 dst_ip,
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->ctrl_info.in_dst_ip == dst_ip) {
 			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
@@ -59,7 +59,7 @@ static in_cache_entry *in_cache_get_with_mask(__be32 dst_ip,
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if ((entry->ctrl_info.in_dst_ip & mask) == (dst_ip & mask)) {
 			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
@@ -80,7 +80,7 @@ static in_cache_entry *in_cache_get_by_vcc(struct atm_vcc *vcc,
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->shortcut == vcc) {
 			refcount_inc(&entry->use);
 			read_unlock_bh(&client->ingress_lock);
@@ -108,7 +108,7 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 	write_lock_bh(&client->ingress_lock);
 	entry->next = client->in_cache;
 	entry->prev = NULL;
-	if (client->in_cache != NULL)
+	if (client->in_cache)
 		client->in_cache->prev = entry;
 	client->in_cache = entry;
 
@@ -133,7 +133,7 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 	struct k_message msg;
 
 	entry->count++;
-	if (entry->entry_state == INGRESS_RESOLVED && entry->shortcut != NULL)
+	if (entry->entry_state == INGRESS_RESOLVED && entry->shortcut)
 		return OPEN;
 
 	if (entry->entry_state == INGRESS_REFRESHING) {
@@ -142,18 +142,18 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 			msg.content.in_info = entry->ctrl_info;
 			memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN);
 			qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-			if (qos != NULL)
+			if (qos)
 				msg.qos = qos->qos;
 			msg_to_mpoad(&msg, mpc);
 			do_gettimeofday(&(entry->reply_wait));
 			entry->entry_state = INGRESS_RESOLVING;
 		}
-		if (entry->shortcut != NULL)
+		if (entry->shortcut)
 			return OPEN;
 		return CLOSED;
 	}
 
-	if (entry->entry_state == INGRESS_RESOLVING && entry->shortcut != NULL)
+	if (entry->entry_state == INGRESS_RESOLVING && entry->shortcut)
 		return OPEN;
 
 	if (entry->count > mpc->parameters.mpc_p1 &&
@@ -165,7 +165,7 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 		memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN);
 		msg.content.in_info = entry->ctrl_info;
 		qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-		if (qos != NULL)
+		if (qos)
 			msg.qos = qos->qos;
 		msg_to_mpoad(&msg, mpc);
 		do_gettimeofday(&(entry->reply_wait));
@@ -195,23 +195,24 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 	dprintk("removing an ingress entry, ip = %pI4\n",
 		&entry->ctrl_info.in_dst_ip);
 
-	if (entry->prev != NULL)
+	if (entry->prev)
 		entry->prev->next = entry->next;
 	else
 		client->in_cache = entry->next;
-	if (entry->next != NULL)
+	if (entry->next)
 		entry->next->prev = entry->prev;
 	client->in_ops->put(entry);
-	if (client->in_cache == NULL && client->eg_cache == NULL) {
+	if (!client->in_cache && !client->eg_cache) {
 		msg.type = STOP_KEEP_ALIVE_SM;
 		msg_to_mpoad(&msg, client);
 	}
 
 	/* Check if the egress side still uses this VCC */
-	if (vcc != NULL) {
+	if (vcc) {
 		eg_cache_entry *eg_entry = client->eg_ops->get_by_vcc(vcc,
 								      client);
-		if (eg_entry != NULL) {
+
+		if (eg_entry) {
 			client->eg_ops->put(eg_entry);
 			return;
 		}
@@ -230,7 +231,7 @@ static void clear_count_and_expired(struct mpoa_client *client)
 
 	write_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while (entry != NULL) {
+	while (entry) {
 		entry->count = 0;
 		next_entry = entry->next;
 		if ((now.tv_sec - entry->tv.tv_sec)
@@ -257,7 +258,7 @@ static void check_resolving_entries(struct mpoa_client *client)
 
 	read_lock_bh(&client->ingress_lock);
 	entry = client->in_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->entry_state == INGRESS_RESOLVING) {
 			if ((now.tv_sec - entry->hold_down.tv_sec) <
 			    client->parameters.mpc_p6) {
@@ -283,7 +284,7 @@ static void check_resolving_entries(struct mpoa_client *client)
 				memcpy(msg.MPS_ctrl, client->mps_ctrl_addr, ATM_ESA_LEN);
 				msg.content.in_info = entry->ctrl_info;
 				qos = atm_mpoa_search_qos(entry->ctrl_info.in_dst_ip);
-				if (qos != NULL)
+				if (qos)
 					msg.qos = qos->qos;
 				msg_to_mpoad(&msg, client);
 				do_gettimeofday(&(entry->reply_wait));
@@ -304,7 +305,7 @@ static void refresh_entries(struct mpoa_client *client)
 	do_gettimeofday(&now);
 
 	read_lock_bh(&client->ingress_lock);
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->entry_state == INGRESS_RESOLVED) {
 			if (!(entry->refresh_time))
 				entry->refresh_time = (2 * (entry->ctrl_info.holding_time))/3;
@@ -323,7 +324,7 @@ static void refresh_entries(struct mpoa_client *client)
 static void in_destroy_cache(struct mpoa_client *mpc)
 {
 	write_lock_irq(&mpc->ingress_lock);
-	while (mpc->in_cache != NULL)
+	while (mpc->in_cache)
 		mpc->in_ops->remove_entry(mpc->in_cache, mpc);
 	write_unlock_irq(&mpc->ingress_lock);
 }
@@ -335,7 +336,7 @@ static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id,
 
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->ctrl_info.cache_id == cache_id) {
 			refcount_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
@@ -356,7 +357,7 @@ static eg_cache_entry *eg_cache_get_by_tag(__be32 tag, struct mpoa_client *mpc)
 
 	read_lock_irqsave(&mpc->egress_lock, flags);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->ctrl_info.tag == tag) {
 			refcount_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
@@ -378,7 +379,7 @@ static eg_cache_entry *eg_cache_get_by_vcc(struct atm_vcc *vcc,
 
 	read_lock_irqsave(&mpc->egress_lock, flags);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->shortcut == vcc) {
 			refcount_inc(&entry->use);
 			read_unlock_irqrestore(&mpc->egress_lock, flags);
@@ -398,7 +399,7 @@ static eg_cache_entry *eg_cache_get_by_src_ip(__be32 ipaddr,
 
 	read_lock_irq(&mpc->egress_lock);
 	entry = mpc->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		if (entry->latest_ip_addr == ipaddr) {
 			refcount_inc(&entry->use);
 			read_unlock_irq(&mpc->egress_lock);
@@ -430,22 +431,22 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 
 	vcc = entry->shortcut;
 	dprintk("removing an egress entry.\n");
-	if (entry->prev != NULL)
+	if (entry->prev)
 		entry->prev->next = entry->next;
 	else
 		client->eg_cache = entry->next;
-	if (entry->next != NULL)
+	if (entry->next)
 		entry->next->prev = entry->prev;
 	client->eg_ops->put(entry);
-	if (client->in_cache == NULL && client->eg_cache == NULL) {
+	if (!client->in_cache && !client->eg_cache) {
 		msg.type = STOP_KEEP_ALIVE_SM;
 		msg_to_mpoad(&msg, client);
 	}
 
 	/* Check if the ingress side still uses this VCC */
-	if (vcc != NULL) {
+	if (vcc) {
 		in_cache_entry *in_entry = client->in_ops->get_by_vcc(vcc, client);
-		if (in_entry != NULL) {
+		if (in_entry) {
 			client->in_ops->put(in_entry);
 			return;
 		}
@@ -469,7 +470,7 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
 	write_lock_irq(&client->egress_lock);
 	entry->next = client->eg_cache;
 	entry->prev = NULL;
-	if (client->eg_cache != NULL)
+	if (client->eg_cache)
 		client->eg_cache->prev = entry;
 	client->eg_cache = entry;
 
@@ -505,7 +506,7 @@ static void clear_expired(struct mpoa_client *client)
 
 	write_lock_irq(&client->egress_lock);
 	entry = client->eg_cache;
-	while (entry != NULL) {
+	while (entry) {
 		next_entry = entry->next;
 		if ((now.tv_sec - entry->tv.tv_sec)
 		   > entry->ctrl_info.holding_time) {
@@ -524,7 +525,7 @@ static void clear_expired(struct mpoa_client *client)
 static void eg_destroy_cache(struct mpoa_client *mpc)
 {
 	write_lock_irq(&mpc->egress_lock);
-	while (mpc->eg_cache != NULL)
+	while (mpc->eg_cache)
 		mpc->eg_ops->remove_entry(mpc->eg_cache, mpc);
 	write_unlock_irq(&mpc->egress_lock);
 }
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 21d9d341a619..890eb377e2dd 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -183,7 +183,7 @@ static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
 	pr_debug("\n");
-	if (skb == NULL) {			/* VCC was closed */
+	if (!skb) {			/* VCC was closed */
 		struct module *module;
 
 		pr_debug("removing ATMPPP VCC %p\n", pvcc);
@@ -202,7 +202,7 @@ static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 		skb_pull(skb, LLC_LEN);
 		break;
 	case e_autodetect:
-		if (pvcc->chan.ppp == NULL) {	/* Not bound yet! */
+		if (!pvcc->chan.ppp) {	/* Not bound yet! */
 			kfree_skb(skb);
 			return;
 		}
@@ -324,14 +324,13 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 		if (skb_headroom(skb) < LLC_LEN) {
 			struct sk_buff *n;
 			n = skb_realloc_headroom(skb, LLC_LEN);
-			if (n != NULL &&
-			    !pppoatm_may_send(pvcc, n->truesize)) {
+			if (n && !pppoatm_may_send(pvcc, n->truesize)) {
 				kfree_skb(n);
 				goto nospace;
 			}
 			consume_skb(skb);
 			skb = n;
-			if (skb == NULL) {
+			if (!skb) {
 				bh_unlock_sock(sk_atm(vcc));
 				return DROP_PACKET;
 			}
@@ -406,7 +405,7 @@ static int pppoatm_assign_vcc(struct atm_vcc *atmvcc, void __user *arg)
 	    be.encaps != PPPOATM_ENCAPS_VC && be.encaps != PPPOATM_ENCAPS_LLC)
 		return -EINVAL;
 	pvcc = kzalloc(sizeof(*pvcc), GFP_KERNEL);
-	if (pvcc == NULL)
+	if (!pvcc)
 		return -ENOMEM;
 	pvcc->atmvcc = atmvcc;
 
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 4caca2a90ec4..aa230079cf8a 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -118,7 +118,7 @@ static int __vcc_seq_open(struct inode *inode, struct file *file,
 	struct vcc_state *state;
 
 	state = __seq_open_private(file, ops, sizeof(*state));
-	if (state == NULL)
+	if (!state)
 		return -ENOMEM;
 
 	state->family = family;
-- 
2.14.2
