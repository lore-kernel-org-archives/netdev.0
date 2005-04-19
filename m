From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
Subject: [PATCH][SOCK] on failure free the sock from the right place
Date: Tue, 19 Apr 2005 01:59:14 -0300
Message-ID: <20050419045914.GD9433@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

	Please apply.

Best Regards,

- Arnaldo

------------------------------------------------------------------------

Author: acme
Date: 2005-04-19 01:53:49 -0300 (Tue, 19 Apr 2005)
New Revision: 68

Modified:
   trunk/net/core/sock.c
Log:
[SOCK] on failure free the sock from the right place

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: David S. Miller <davem@davemloft.net>


Modified: trunk/net/core/sock.c
===================================================================
--- trunk/net/core/sock.c	2005-04-19 02:32:15 UTC (rev 67)
+++ trunk/net/core/sock.c	2005-04-19 04:53:49 UTC (rev 68)
@@ -642,7 +642,10 @@
 		}
 		
 		if (security_sk_alloc(sk, family, priority)) {
-			kmem_cache_free(slab, sk);
+			if (slab != NULL)
+				kmem_cache_free(slab, sk);
+			else
+				kfree(sk);
 			sk = NULL;
 		} else
 			__module_get(prot->owner);
