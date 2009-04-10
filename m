From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 07/12] RDS: use get_user_pages_fast()
Date: Thu,  9 Apr 2009 17:09:42 -0700
Message-ID: <1239322187-3764-8-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:23061 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937461AbZDJAKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:08 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n3A0A9pV008916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2009 00:10:10 GMT
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new function that is simpler and faster.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/info.c |    5 +----
 net/rds/rdma.c |    5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/rds/info.c b/net/rds/info.c
index 1d88553..62aeef3 100644
--- a/net/rds/info.c
+++ b/net/rds/info.c
@@ -188,10 +188,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
 		ret = -ENOMEM;
 		goto out;
 	}
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, start, nr_pages, 1, 0,
-			     pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_fast(start, nr_pages, 1, pages);
 	if (ret != nr_pages) {
 		if (ret > 0)
 			nr_pages = ret;
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index e390dc7..8dc83d2 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -150,10 +150,7 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 {
 	int ret;
 
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, user_addr,
-			     nr_pages, write, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_fast(user_addr, nr_pages, write, pages);
 
 	if (ret >= 0 && ret < nr_pages) {
 		while (ret--)
-- 
1.5.6.3

