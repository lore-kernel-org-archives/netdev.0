From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 1/4] xfrm_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 18:02:30 +0900
Message-ID: <007c01c8300b$176975a0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:60035 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbXKZJCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 04:02:45 -0500
Received: by wa-out-1112.google.com with SMTP id v27so658368wah
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 01:02:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xfrm_hash: kmalloc + memset conversion to kzalloc

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

Thanks.
Joonwoo

---
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
index 55ab579..37795bd 100644
--- a/net/xfrm/xfrm_hash.c
+++ b/net/xfrm/xfrm_hash.c
@@ -17,16 +17,17 @@ struct hlist_head *xfrm_hash_alloc(unsigned int sz)
 	struct hlist_head *n;
 
 	if (sz <= PAGE_SIZE)
-		n = kmalloc(sz, GFP_KERNEL);
-	else if (hashdist)
-		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
-	else
-		n = (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL | __GFP_NOWARN,
-					 get_order(sz));
-
-	if (n)
-		memset(n, 0, sz);
+		n = kzalloc(sz, GFP_KERNEL);
+	else {
+		if (hashdist)
+			n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
+		else
+			n = (struct hlist_head *)
+				__get_free_pages(GFP_KERNEL | __GFP_NOWARN,
+						 get_order(sz));
+		if (n)
+			memset(n, 0, sz);
+	}
 
 	return n;
 }
---

