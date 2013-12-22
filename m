From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2] nfs: fix dead code of ipv6_addr_scope
Date: Mon, 23 Dec 2013 00:01:16 +0100
Message-ID: <1387753276-27009-1-git-send-email-alex.aring@gmail.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, werner@almesberger.net,
	Alexander Aring <alex.aring@gmail.com>
To: hannes@stressinduktion.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch corrects the check on a linklocal address.

Currently this can't be work, because ipv6_addr_scope returns a int with
a mask of IPV6_ADDR_SCOPE_MASK (0x00f0U) and IPV6_ADDR_SCOPE_LINKLOCAL
is 0x02. So the condition is always false.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
- change check on linklocal address from
  (ipv6_addr_src_scope(&a6->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL) to
  (ipv6_addr_scope(&a6->sin6_addr) & IPV6_ADDR_LINKLOCAL) which is a
  little bit faster.
- change commit msg.

 fs/nfs/nfs4filelayoutdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c7c295e5..dc5e9e1 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -95,8 +95,7 @@ same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 		b6 = (struct sockaddr_in6 *)addr2;
 
 		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_scope(&a6->sin6_addr) ==
-		    IPV6_ADDR_SCOPE_LINKLOCAL &&
+		if (ipv6_addr_scope(&a6->sin6_addr) & IPV6_ADDR_LINKLOCAL &&
 		    a6->sin6_scope_id != b6->sin6_scope_id)
 			return false;
 
-- 
1.8.5.2
