From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 6/9] RDS: Fix ordering in a conditional
Date: Mon, 30 Mar 2009 11:44:50 -0700
Message-ID: <1238438693-29540-7-git-send-email-andy.grover@oracle.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:58036 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758937AbZC3SpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:45:16 -0400
Received: from acsinet13.oracle.com (acsinet13.oracle.com [141.146.126.235])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2UIjCYw009106
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 18:45:13 GMT
In-Reply-To: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Putting the constant first is a supposed "best practice" that actually makes
the code harder to read.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index eaeeb91..584eac3 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -155,7 +155,7 @@ static int rds_pin_pages(unsigned long user_addr, unsigned int nr_pages,
 			     nr_pages, write, 0, pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
-	if (0 <= ret && (unsigned) ret < nr_pages) {
+	if (ret > 0 && (unsigned) ret < nr_pages) {
 		while (ret--)
 			put_page(pages[ret]);
 		ret = -EFAULT;
-- 
1.5.6.3

