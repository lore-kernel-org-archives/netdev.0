From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 4/6] enic: Bug fix: align desc ring sizes to 32 descs
Date: Fri, 18 Dec 2009 18:09:56 -0800
Message-ID: <20091219020956.2745.51293.stgit@savbu-pc100.cisco.com>
References: <20091219020758.2745.85264.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:13472 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684AbZLSCJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 21:09:57 -0500
In-Reply-To: <20091219020758.2745.85264.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: Bug fix: align desc ring sizes to 32 descs

Previous driver was aligning ring sizes to 16 descs, but hardware actually
wants desc ring sizes to be aligned to 32 descs.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
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

