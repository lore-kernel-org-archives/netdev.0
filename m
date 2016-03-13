From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/3] libceph: use KMEM_CACHE macro
Date: Sun, 13 Mar 2016 15:18:39 +0800
Message-ID: <a9c3e96ba6bf321ca13d9445d2770781fb7033cd.1457853190.git.geliangtang@163.com>
References: <9242267d62daeec8a0de5a1230f750ca486d62cd.1457853190.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:55510 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932252AbcCMHS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 03:18:58 -0400
In-Reply-To: <9242267d62daeec8a0de5a1230f750ca486d62cd.1457853190.git.geliangtang@163.com>
In-Reply-To: <9242267d62daeec8a0de5a1230f750ca486d62cd.1457853190.git.geliangtang@163.com>
References: <9242267d62daeec8a0de5a1230f750ca486d62cd.1457853190.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use KMEM_CACHE() instead of kmem_cache_create() to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/ceph/messenger.c  | 10 ++--------
 net/ceph/osd_client.c |  5 +----
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9382619..32c997e 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -235,18 +235,12 @@ static struct workqueue_struct *ceph_msgr_wq;
 static int ceph_msgr_slab_init(void)
 {
 	BUG_ON(ceph_msg_cache);
-	ceph_msg_cache = kmem_cache_create("ceph_msg",
-					sizeof (struct ceph_msg),
-					__alignof__(struct ceph_msg), 0, NULL);
-
+	ceph_msg_cache = KMEM_CACHE(ceph_msg, 0);
 	if (!ceph_msg_cache)
 		return -ENOMEM;
 
 	BUG_ON(ceph_msg_data_cache);
-	ceph_msg_data_cache = kmem_cache_create("ceph_msg_data",
-					sizeof (struct ceph_msg_data),
-					__alignof__(struct ceph_msg_data),
-					0, NULL);
+	ceph_msg_data_cache = KMEM_CACHE(ceph_msg_data, 0);
 	if (ceph_msg_data_cache)
 		return 0;
 
diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 5bc0537..7558855 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -2783,10 +2783,7 @@ EXPORT_SYMBOL(ceph_osdc_writepages);
 int ceph_osdc_setup(void)
 {
 	BUG_ON(ceph_osd_request_cache);
-	ceph_osd_request_cache = kmem_cache_create("ceph_osd_request",
-					sizeof (struct ceph_osd_request),
-					__alignof__(struct ceph_osd_request),
-					0, NULL);
+	ceph_osd_request_cache = KMEM_CACHE(ceph_osd_request, 0);
 
 	return ceph_osd_request_cache ? 0 : -ENOMEM;
 }
-- 
2.5.0
