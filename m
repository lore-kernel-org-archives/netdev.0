From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 2/5] RDS: Return -EINVAL if rds_rdma_pages returns an error
Date: Thu, 28 Oct 2010 18:40:56 -0700
Message-ID: <1288316459-4679-3-git-send-email-andy.grover@oracle.com>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43943 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757270Ab0J2Bl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:41:57 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9T1ftHs030896
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:41:57 GMT
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_cmsg_rdma_args would still return success even if rds_rdma_pages
returned an error (or overflowed).

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 0df02c8..d0ba2ca 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -554,8 +554,10 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	}
 
 	nr_pages = rds_rdma_pages(args);
-	if (nr_pages < 0)
+	if (nr_pages < 0) {
+		ret = -EINVAL;
 		goto out;
+	}
 
 	pages = kcalloc(nr_pages, sizeof(struct page *), GFP_KERNEL);
 	if (!pages) {
-- 
1.7.1

