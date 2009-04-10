From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 05/12] RDS: Fix ordering in a conditional
Date: Thu,  9 Apr 2009 17:09:40 -0700
Message-ID: <1239322187-3764-6-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53279 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937023AbZDJAKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:04 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n3A0BF75027104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2009 00:11:17 GMT
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Putting the constant first is a supposed "best practice" that actually makes
the code harder to read.

Thanks to Roland Dreier for finding a bug in this "simple, obviously correct"
patch.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index eaeeb91..e390dc7 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -155,7 +155,7 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 			     nr_pages, write, 0, pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
-	if (0 <= ret && (unsigned) ret < nr_pages) {
+	if (ret >= 0 && ret < nr_pages) {
 		while (ret--)
 			put_page(pages[ret]);
 		ret = -EFAULT;
-- 
1.5.6.3

