From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: [PATCH v4 1/2] RDS: memory allocated must be align to 8
Date: Thu,  7 Apr 2016 07:57:35 -0400
Message-ID: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: davem@davemloft.net, shamir.rabinovitch@oracle.com,
	santosh.shilimkar@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50493 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbcDGL57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 07:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix issue in 'rds_ib_cong_recv' when accessing unaligned memory
allocated by 'rds_page_remainder_alloc' using uint64_t pointer.

Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
---
 net/rds/page.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/page.c b/net/rds/page.c
index 616f21f..e2b5a58 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -135,8 +135,8 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
 			if (rem->r_offset != 0)
 				rds_stats_inc(s_page_remainder_hit);
 
-			rem->r_offset += bytes;
-			if (rem->r_offset == PAGE_SIZE) {
+			rem->r_offset += ALIGN(bytes, 8);
+			if (rem->r_offset >= PAGE_SIZE) {
 				__free_page(rem->r_page);
 				rem->r_page = NULL;
 			}
-- 
1.7.1
