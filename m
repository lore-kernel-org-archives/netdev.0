From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/19] cxgb4i: Convert over to dst_neigh_lookup().
Date: Tue, 03 Jul 2012 02:46:35 -0700 (PDT)
Message-ID: <20120703.024635.1262203293686089551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab2GCJqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:35 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 68BCA584120
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 5a4a3bf..cc9a068 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1142,7 +1142,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	n = dst_get_neighbour_noref(csk->dst);
+	n = dst_neigh_lookup(csk->dst, &csk->daddr.sin_addr.s_addr);
 	if (!n) {
 		pr_err("%s, can't get neighbour of csk->dst.\n", ndev->name);
 		goto rel_resource;
@@ -1182,9 +1182,12 @@ static int init_act_open(struct cxgbi_sock *csk)
 
 	cxgbi_sock_set_state(csk, CTP_ACTIVE_OPEN);
 	send_act_open_req(csk, skb, csk->l2t);
+	neigh_release(n);
 	return 0;
 
 rel_resource:
+	if (n)
+		neigh_release(n);
 	if (skb)
 		__kfree_skb(skb);
 	return -EINVAL;
-- 
1.7.10
