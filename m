From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 4/6] enic: Bug fix: align desc ring sizes to 32 descs
Date: Wed, 23 Dec 2009 15:27:48 -0800
Message-ID: <20091223232748.19428.7769.stgit@savbu-pc100.cisco.com>
References: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6154 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196AbZLWX1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:49 -0500
In-Reply-To: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Previous driver was aligning ring sizes to 16 descs, but hardware actually
wants desc ring sizes to be aligned to 32 descs.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_res.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 3211114..a605da1 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -74,13 +74,13 @@ int enic_get_vnic_config(struct enic *enic)
 		min_t(u32, ENIC_MAX_WQ_DESCS,
 		max_t(u32, ENIC_MIN_WQ_DESCS,
 		c->wq_desc_count));
-	c->wq_desc_count &= 0xfffffff0; /* must be aligned to groups of 16 */
+	c->wq_desc_count &= 0xffffffe0; /* must be aligned to groups of 32 */
 
 	c->rq_desc_count =
 		min_t(u32, ENIC_MAX_RQ_DESCS,
 		max_t(u32, ENIC_MIN_RQ_DESCS,
 		c->rq_desc_count));
-	c->rq_desc_count &= 0xfffffff0; /* must be aligned to groups of 16 */
+	c->rq_desc_count &= 0xffffffe0; /* must be aligned to groups of 32 */
 
 	if (c->mtu == 0)
 		c->mtu = 1500;

