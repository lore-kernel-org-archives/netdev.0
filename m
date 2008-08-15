From: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
Subject: [PATCH] Remove duplicated unlikely() in IS_ERR()
Date: Fri, 15 Aug 2008 16:16:57 +0900
Message-ID: <48A52D69.1040501@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: christof.schmitt@de.ibm.com, dedekind@infradead.org,
	yoshfuji@linux-ipv6.org, linux-mtd@lists.infradead.org,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:58133 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbYHOH1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 03:27:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
Some drivers have duplicated unlikely() macros.
IS_ERR() already has unlikely() in itself.
This patch cleans up such pointless codes although there is no real
effect on the kernel's behaviour.

Thanks,
Hirofumi Nakagawa

Signed-off-by: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
---
 drivers/s390/scsi/zfcp_fsf.c |   32 ++++++++++++++++----------------
 fs/ubifs/find.c              |    4 ++--
 fs/ubifs/gc.c                |    8 ++++----
 fs/ubifs/tnc.c               |    4 ++--
 fs/ubifs/xattr.c             |    2 +-
 net/ipv6/af_inet6.c          |    2 +-
 6 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/s390/scsi/zfcp_fsf.c b/drivers/s390/scsi/zfcp_fsf.c
index 19c1ca9..6e23759 100644
--- a/drivers/s390/scsi/zfcp_fsf.c
+++ b/drivers/s390/scsi/zfcp_fsf.c
@@ -877,7 +877,7 @@ int zfcp_fsf_status_read(struct zfcp_adapter *adapter)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_UNSOLICITED_STATUS,
 				  ZFCP_REQ_NO_QTCB,
 				  adapter->pool.fsf_req_status_read);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -988,7 +988,7 @@ struct zfcp_fsf_req *zfcp_fsf_abort_fcp_command(unsigned long old_req_id,
 		goto out;
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_ABORT_FCP_CMND,
 				  req_flags, adapter->pool.fsf_req_abort);
-	if (unlikely(IS_ERR(req)))
+	if (IS_ERR(req))
 		goto out;

 	if (unlikely(!(atomic_read(&unit->status) &
@@ -1112,7 +1112,7 @@ int zfcp_fsf_send_ct(struct zfcp_send_ct *ct, mempool_t *pool,

 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_SEND_GENERIC,
 				  ZFCP_REQ_AUTO_CLEANUP, pool);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		ret = PTR_ERR(req);
 		goto out;
 	}
@@ -1223,7 +1223,7 @@ int zfcp_fsf_send_els(struct zfcp_send_els *els)
 		goto out;
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_SEND_ELS,
 				  ZFCP_REQ_AUTO_CLEANUP, NULL);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		ret = PTR_ERR(req);
 		goto out;
 	}
@@ -1270,7 +1270,7 @@ int zfcp_fsf_exchange_config_data(struct zfcp_erp_action *erp_action)
 				  FSF_QTCB_EXCHANGE_CONFIG_DATA,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1312,7 +1312,7 @@ int zfcp_fsf_exchange_config_data_sync(struct zfcp_adapter *adapter,

 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_EXCHANGE_CONFIG_DATA,
 				  0, NULL);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1365,7 +1365,7 @@ int zfcp_fsf_exchange_port_data(struct zfcp_erp_action *erp_action)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_EXCHANGE_PORT_DATA,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1411,7 +1411,7 @@ int zfcp_fsf_exchange_port_data_sync(struct zfcp_adapter *adapter,

 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_EXCHANGE_PORT_DATA, 0,
 				  NULL);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1539,7 +1539,7 @@ int zfcp_fsf_open_port(struct zfcp_erp_action *erp_action)
 				  FSF_QTCB_OPEN_PORT_WITH_DID,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1610,7 +1610,7 @@ int zfcp_fsf_close_port(struct zfcp_erp_action *erp_action)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_CLOSE_PORT,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1707,7 +1707,7 @@ int zfcp_fsf_close_physical_port(struct zfcp_erp_action *erp_action)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_CLOSE_PHYSICAL_PORT,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1882,7 +1882,7 @@ int zfcp_fsf_open_unit(struct zfcp_erp_action *erp_action)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_OPEN_LUN,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -1971,7 +1971,7 @@ int zfcp_fsf_close_unit(struct zfcp_erp_action *erp_action)
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_CLOSE_LUN,
 				  ZFCP_REQ_AUTO_CLEANUP,
 				  adapter->pool.fsf_req_erp);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -2228,7 +2228,7 @@ int zfcp_fsf_send_fcp_command_task(struct zfcp_adapter *adapter,
 		goto out;
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_FCP_CMND, req_flags,
 				  adapter->pool.fsf_req_scsi);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = PTR_ERR(req);
 		goto out;
 	}
@@ -2351,7 +2351,7 @@ struct zfcp_fsf_req *zfcp_fsf_send_fcp_ctm(struct zfcp_adapter *adapter,
 		goto out;
 	req = zfcp_fsf_req_create(adapter, FSF_QTCB_FCP_CMND, req_flags,
 				  adapter->pool.fsf_req_scsi);
-	if (unlikely(IS_ERR(req)))
+	if (IS_ERR(req))
 		goto out;

 	req->status |= ZFCP_STATUS_FSFREQ_TASK_MANAGEMENT;
@@ -2422,7 +2422,7 @@ struct zfcp_fsf_req *zfcp_fsf_control_file(struct zfcp_adapter *adapter,
 		goto out;

 	req = zfcp_fsf_req_create(adapter, fsf_cfdc->command, 0, NULL);
-	if (unlikely(IS_ERR(req))) {
+	if (IS_ERR(req)) {
 		retval = -EPERM;
 		goto out;
 	}
diff --git a/fs/ubifs/find.c b/fs/ubifs/find.c
index 10394c5..a5d6d50 100644
--- a/fs/ubifs/find.c
+++ b/fs/ubifs/find.c
@@ -899,11 +899,11 @@ static int get_idx_gc_leb(struct ubifs_info *c)
 	 * it is needed now for this commit.
 	 */
 	lp = ubifs_lpt_lookup_dirty(c, lnum);
-	if (unlikely(IS_ERR(lp)))
+	if (IS_ERR(lp))
 		return PTR_ERR(lp);
 	lp = ubifs_change_lp(c, lp, LPROPS_NC, LPROPS_NC,
 			     lp->flags | LPROPS_INDEX, -1);
-	if (unlikely(IS_ERR(lp)))
+	if (IS_ERR(lp))
 		return PTR_ERR(lp);
 	dbg_find("LEB %d, dirty %d and free %d flags %#x",
 		 lp->lnum, lp->dirty, lp->free, lp->flags);
diff --git a/fs/ubifs/gc.c b/fs/ubifs/gc.c
index d0f3dac..07dd809 100644
--- a/fs/ubifs/gc.c
+++ b/fs/ubifs/gc.c
@@ -639,7 +639,7 @@ int ubifs_gc_start_commit(struct ubifs_info *c)
 	 */
 	while (1) {
 		lp = ubifs_fast_find_freeable(c);
-		if (unlikely(IS_ERR(lp))) {
+		if (IS_ERR(lp)) {
 			err = PTR_ERR(lp);
 			goto out;
 		}
@@ -651,7 +651,7 @@ int ubifs_gc_start_commit(struct ubifs_info *c)
 		if (err)
 			goto out;
 		lp = ubifs_change_lp(c, lp, c->leb_size, 0, lp->flags, 0);
-		if (unlikely(IS_ERR(lp))) {
+		if (IS_ERR(lp)) {
 			err = PTR_ERR(lp);
 			goto out;
 		}
@@ -666,7 +666,7 @@ int ubifs_gc_start_commit(struct ubifs_info *c)
 	/* Record index freeable LEBs for unmapping after commit */
 	while (1) {
 		lp = ubifs_fast_find_frdi_idx(c);
-		if (unlikely(IS_ERR(lp))) {
+		if (IS_ERR(lp)) {
 			err = PTR_ERR(lp);
 			goto out;
 		}
@@ -682,7 +682,7 @@ int ubifs_gc_start_commit(struct ubifs_info *c)
 		/* Don't release the LEB until after the next commit */
 		flags = (lp->flags | LPROPS_TAKEN) ^ LPROPS_INDEX;
 		lp = ubifs_change_lp(c, lp, c->leb_size, 0, flags, 1);
-		if (unlikely(IS_ERR(lp))) {
+		if (IS_ERR(lp)) {
 			err = PTR_ERR(lp);
 			kfree(idx_gc);
 			goto out;
diff --git a/fs/ubifs/tnc.c b/fs/ubifs/tnc.c
index e909f4a..1c735d2 100644
--- a/fs/ubifs/tnc.c
+++ b/fs/ubifs/tnc.c
@@ -284,7 +284,7 @@ static struct ubifs_znode *dirty_cow_znode(struct ubifs_info *c,
 	}

 	zn = copy_znode(c, znode);
-	if (unlikely(IS_ERR(zn)))
+	if (IS_ERR(zn))
 		return zn;

 	if (zbr->len) {
@@ -1128,7 +1128,7 @@ static struct ubifs_znode *dirty_cow_bottom_up(struct ubifs_info *c,
 			ubifs_assert(znode == c->zroot.znode);
 			znode = dirty_cow_znode(c, &c->zroot);
 		}
-		if (unlikely(IS_ERR(znode)) || !p)
+		if (IS_ERR(znode) || !p)
 			break;
 		ubifs_assert(path[p - 1] >= 0);
 		ubifs_assert(path[p - 1] < znode->child_cnt);
diff --git a/fs/ubifs/xattr.c b/fs/ubifs/xattr.c
index 1388a07..b4e039c 100644
--- a/fs/ubifs/xattr.c
+++ b/fs/ubifs/xattr.c
@@ -455,7 +455,7 @@ ssize_t ubifs_listxattr(struct dentry *dentry, char *buffer, size_t size)
 		int type;

 		xent = ubifs_tnc_next_ent(c, &key, &nm);
-		if (unlikely(IS_ERR(xent))) {
+		if (IS_ERR(xent)) {
 			err = PTR_ERR(xent);
 			break;
 		}
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 95055f8..b67e2b0 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -763,7 +763,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	}
 	rcu_read_unlock();

-	if (unlikely(IS_ERR(segs)))
+	if (IS_ERR(segs))
 		goto out;

 	for (skb = segs; skb; skb = skb->next) {
-- 
1.5.4.1


