From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 13/13] RDS: Enable per-cpu workqueue threads
Date: Thu, 11 Mar 2010 15:50:07 -0800
Message-ID: <1268351407-7394-14-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Tina Yang <tina.yang@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17884 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885Ab0CKXwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:52:24 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNqMWv004166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:52:24 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tina Yang <tina.yang@oracle.com>

Create per-cpu workqueue threads instead of a single
krdsd thread. This is a step towards better scalability.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/threads.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/threads.c b/net/rds/threads.c
index 00fa10e..786c20e 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -259,7 +259,7 @@ void rds_threads_exit(void)
 
 int __init rds_threads_init(void)
 {
-	rds_wq = create_singlethread_workqueue("krdsd");
+	rds_wq = create_workqueue("krdsd");
 	if (rds_wq == NULL)
 		return -ENOMEM;
 
-- 
1.6.3.3

