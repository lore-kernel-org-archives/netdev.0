From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: use kasprintf() for socket cache names
Date: Wed, 17 Feb 2010 21:34:12 +0200
Message-ID: <20100217193411.GC5256@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f200.google.com ([209.85.221.200]:58379 "EHLO
	mail-qy0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab0BQTeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 14:34:13 -0500
Received: by qyk38 with SMTP id 38so2251485qyk.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 11:34:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kasprintf() makes code smaller.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/sock.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2228,13 +2228,10 @@ int proto_register(struct proto *prot, int alloc_slab)
 		}
 
 		if (prot->rsk_prot != NULL) {
-			static const char mask[] = "request_sock_%s";
-
-			prot->rsk_prot->slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			prot->rsk_prot->slab_name = kasprintf(GFP_KERNEL, "request_sock_%s", prot->name);
 			if (prot->rsk_prot->slab_name == NULL)
 				goto out_free_sock_slab;
 
-			sprintf(prot->rsk_prot->slab_name, mask, prot->name);
 			prot->rsk_prot->slab = kmem_cache_create(prot->rsk_prot->slab_name,
 								 prot->rsk_prot->obj_size, 0,
 								 SLAB_HWCACHE_ALIGN, NULL);
@@ -2247,14 +2244,11 @@ int proto_register(struct proto *prot, int alloc_slab)
 		}
 
 		if (prot->twsk_prot != NULL) {
-			static const char mask[] = "tw_sock_%s";
-
-			prot->twsk_prot->twsk_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			prot->twsk_prot->twsk_slab_name = kasprintf(GFP_KERNEL, "tw_sock_%s", prot->name);
 
 			if (prot->twsk_prot->twsk_slab_name == NULL)
 				goto out_free_request_sock_slab;
 
-			sprintf(prot->twsk_prot->twsk_slab_name, mask, prot->name);
 			prot->twsk_prot->twsk_slab =
 				kmem_cache_create(prot->twsk_prot->twsk_slab_name,
 						  prot->twsk_prot->twsk_obj_size,
