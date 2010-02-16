From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 49/62: don't use INIT_RCU_HEAD()
Date: Tue, 16 Feb 2010 15:56:26 +0100 (MET)
Message-ID: <20100216145624.2796.90417.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52091 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729Ab0BPO41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:27 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ca1c2e2da9637c131436bf6d6ae41b58f5353afe
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Fri Feb 12 06:25:36 2010 +0100

    netfilter: don't use INIT_RCU_HEAD()
    
    call_rcu() will unconditionally reinitialize RCU head anyway.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 33b85f8..6182fb1 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -232,7 +232,6 @@ struct nf_conntrack_expect *nf_ct_expect_alloc(struct nf_conn *me)
 
 	new->master = me;
 	atomic_set(&new->use, 1);
-	INIT_RCU_HEAD(&new->rcu);
 	return new;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_alloc);
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index fef95be..fdc8fb4 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -59,7 +59,6 @@ nf_ct_ext_create(struct nf_ct_ext **ext, enum nf_ct_ext_id id, gfp_t gfp)
 	if (!*ext)
 		return NULL;
 
-	INIT_RCU_HEAD(&(*ext)->rcu);
 	(*ext)->offset[id] = off;
 	(*ext)->len = len;
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 90cf36d..7ba4abc 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -112,7 +112,6 @@ instance_create(u_int16_t queue_num, int pid)
 	inst->copy_mode = NFQNL_COPY_NONE;
 	spin_lock_init(&inst->lock);
 	INIT_LIST_HEAD(&inst->queue_list);
-	INIT_RCU_HEAD(&inst->rcu);
 
 	if (!try_module_get(THIS_MODULE)) {
 		err = -EAGAIN;
