From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 5/10][TCP] minisocks: Use kmemdup and LIMIT_NETDEBUG
Date: Fri, 17 Nov 2006 13:18:07 -0200
Message-ID: <20061117151806.GF17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:38798 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1755704AbWKQPSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:18:30 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/tcp_minisocks.o.before /tmp/tcp_minisocks.o.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp_minisocks.c:
  tcp_check_req |  -44
 1 function changed, 44 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/tcp_minisocks.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 383cb38..6dddf59 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -351,8 +351,7 @@ #endif
 		 * socket up.  We've got bigger problems than
 		 * non-graceful socket closings.
 		 */
-		if (net_ratelimit())
-			printk(KERN_INFO "TCP: time wait bucket table overflow\n");
+		LIMIT_NETDEBUG(KERN_INFO "TCP: time wait bucket table overflow\n");
 	}
 
 	tcp_update_metrics(sk);
@@ -667,11 +666,11 @@ #ifdef CONFIG_TCP_MD5SIG
 				 * newsk structure. If we fail to get memory then we
 				 * end up not copying the key across. Shucks.
 				 */
-				char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
+				char *newkey = kmemdup(key->key, key->keylen,
+						       GFP_ATOMIC);
 				if (newkey) {
 					if (!tcp_alloc_md5sig_pool())
 						BUG();
-					memcpy(newkey, key->key, key->keylen);
 					tp->af_specific->md5_add(child, child,
 								 newkey,
 								 key->keylen);
-- 
1.4.2.1.g3d5c

