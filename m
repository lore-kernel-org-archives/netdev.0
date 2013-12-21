From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] nfs: fix dead code of ipv6_addr_scope
Date: Sat, 21 Dec 2013 05:39:04 +0100
Message-ID: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	werner-SEdMjqphH88wryQfseakQg@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The correct way to check on IPV6_ADDR_SCOPE_LINKLOCAL is to check with
the ipv6_addr_src_scope function.

Currently this can't be work, because ipv6_addr_scope returns a int with
a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
is 0x02. So the condition is always false.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
I think ipv6_addr_src_scope should be correct, can somebody from netdev ml
confirm this please?
I stumple over that and I did not compile and test it. Maybe this is something
for stable?

 fs/nfs/nfs4filelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c7c295e5..efac602 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -95,7 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 		b6 = (struct sockaddr_in6 *)addr2;
 
 		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_scope(&a6->sin6_addr) ==
+		if (ipv6_addr_src_scope(&a6->sin6_addr) ==
 		    IPV6_ADDR_SCOPE_LINKLOCAL &&
 		    a6->sin6_scope_id != b6->sin6_scope_id)
 			return false;
-- 
1.8.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
