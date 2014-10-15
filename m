From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2 4/4] cxgb4i: Remove duplicate call to dst_neigh_lookup()
Date: Tue, 14 Oct 2014 20:07:24 -0700
Message-ID: <1413342444-16388-5-git-send-email-anish@chelsio.com>
References: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, jbottomley@parallels.com,
	kxie@chelsio.com, manojmalviya@chelsio.com, hariprasad@chelsio.com,
	leedom@chelsio.com, swise@opengridcomputing.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44193
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755837AbaJODIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 23:08:02 -0400
In-Reply-To: <1413342444-16388-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an extra call to dst_neigh_lookup() leftover in cxgb4i that can cause 
an unreleased refcnt issue. Remove extraneous call.

Signed-off-by: Anish Bhatt <anish@chelsio.com>

Fixes : 759a0cc5a3e1b ('cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6 api')
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index df176f0..8c3003b 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1317,11 +1317,6 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	n = dst_neigh_lookup(csk->dst, &csk->daddr.sin_addr.s_addr);
-	if (!n) {
-		pr_err("%s, can't get neighbour of csk->dst.\n", ndev->name);
-		goto rel_resource;
-	}
 	csk->l2t = cxgb4_l2t_get(lldi->l2t, n, ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
-- 
2.1.2
