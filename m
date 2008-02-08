From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPSEC] flow: reorder "struct flow_cache_entry" and remove SLAB_HWCACHE_ALIGN
Date: Fri, 08 Feb 2008 08:12:49 +0100
Message-ID: <47AC00F1.9090308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050705050306030009090208"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:36035
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757179AbYBHHM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 02:12:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050705050306030009090208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

1) We can shrink sizeof(struct flow_cache_entry) by 8 bytes on 64bit arches.
2) No need to align these structures to hardware cache lines, this only waste 
  ram for very litle gain.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------050705050306030009090208
Content-Type: text/plain;
 name="flow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="flow.patch"

diff --git a/net/core/flow.c b/net/core/flow.c
index 9cfe845..a77531c 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -30,8 +30,8 @@ struct flow_cache_entry {
 	struct flow_cache_entry	*next;
 	u16			family;
 	u8			dir;
-	struct flowi		key;
 	u32			genid;
+	struct flowi		key;
 	void			*object;
 	atomic_t		*object_ref;
 };
@@ -346,7 +346,7 @@ static int __init flow_cache_init(void)
 
 	flow_cachep = kmem_cache_create("flow_cache",
 					sizeof(struct flow_cache_entry),
-					0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					0, SLAB_PANIC,
 					NULL);
 	flow_hash_shift = 10;
 	flow_lwm = 2 * flow_hash_size;

--------------050705050306030009090208--
