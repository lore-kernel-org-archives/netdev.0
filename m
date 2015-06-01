From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] libceph: use kvfree() in ceph_put_page_vector()
Date: Mon,  1 Jun 2015 22:36:01 +0800
Message-ID: <1433169361-18667-1-git-send-email-geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:59472 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbbFAOgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 10:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kvfree() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/ceph/pagevec.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 096d914..d4f5f22 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -51,10 +51,7 @@ void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 			set_page_dirty_lock(pages[i]);
 		put_page(pages[i]);
 	}
-	if (is_vmalloc_addr(pages))
-		vfree(pages);
-	else
-		kfree(pages);
+	kvfree(pages);
 }
 EXPORT_SYMBOL(ceph_put_page_vector);
 
-- 
2.3.4
