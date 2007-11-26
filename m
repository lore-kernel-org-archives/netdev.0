From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 3/4] fib_hash: kmalloc + memset conversion to kzalloc
Date: Mon, 26 Nov 2007 19:24:03 +0900
Message-ID: <000401c83016$78a9d930$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ro-out-1112.google.com ([72.14.202.181]:58354 "EHLO
	ro-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbXKZKYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:24:15 -0500
Received: by ro-out-1112.google.com with SMTP id p4so978062roc
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 02:24:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fib_hash: kmalloc + memset conversion to kzalloc
fix to avoid memset entirely.

Thanks.
Joonwoo

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>

---
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..9d0cee2 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -102,10 +102,10 @@ static struct hlist_head *fz_hash_alloc(int divisor)
 	unsigned long size = divisor * sizeof(struct hlist_head);
 
 	if (size <= PAGE_SIZE) {
-		return kmalloc(size, GFP_KERNEL);
+		return kzalloc(size, GFP_KERNEL);
 	} else {
 		return (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL, get_order(size));
+			__get_free_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
 	}
 }
 
@@ -174,8 +174,6 @@ static void fn_rehash_zone(struct fn_zone *fz)
 	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
-		memset(ht, 0, new_divisor * sizeof(struct hlist_head));
-
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
 		fz->fz_hash = ht;
@@ -219,7 +217,6 @@ fn_new_zone(struct fn_hash *table, int z)
 		kfree(fz);
 		return NULL;
 	}
-	memset(fz->fz_hash, 0, fz->fz_divisor * sizeof(struct hlist_head *));
 	fz->fz_order = z;
 	fz->fz_mask = inet_make_mask(z);
 
---

