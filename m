From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH 1/4] xfrm_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 19:23:51 +0900
Message-ID: <000301c83016$774dcba0$9c94fea9@jason>
References: <007c01c8300b$176975a0$9c94fea9@jason> <474A8D97.2030808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "'Patrick McHardy'" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ro-out-1112.google.com ([72.14.202.181]:58354 "EHLO
	ro-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997AbXKZKYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:24:11 -0500
Received: by ro-out-1112.google.com with SMTP id p4so978062roc
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 02:24:10 -0800 (PST)
In-Reply-To: <474A8D97.2030808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/26, Patrick McHardy <kaber@trash.net>:
> How about also switching vmalloc/get_free_pages to GFP_ZERO
> and getting rid of the memset entirely while you're at it?
> 

xfrm_hash: kmalloc + memset conversion to kzalloc
fix to avoid memset entirely.
Thanks Patrick.

Thanks.
Joonwoo


Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

---
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
index 55ab579..a2023ec 100644
--- a/net/xfrm/xfrm_hash.c
+++ b/net/xfrm/xfrm_hash.c
@@ -17,17 +17,14 @@ struct hlist_head *xfrm_hash_alloc(unsigned int sz)
 	struct hlist_head *n;
 
 	if (sz <= PAGE_SIZE)
-		n = kmalloc(sz, GFP_KERNEL);
+		n = kzalloc(sz, GFP_KERNEL);
 	else if (hashdist)
-		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
+		n = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	else
 		n = (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL | __GFP_NOWARN,
+			__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
 					 get_order(sz));
 
-	if (n)
-		memset(n, 0, sz);
-
 	return n;
 }
 
---

