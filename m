From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sunrpc: fix rdma dependencies
Date: Tue, 03 Feb 2009 14:13:15 -0800
Message-ID: <4988C17B.1030902@oracle.com>
References: <200902030112.n131CNiq010549@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Roland Dreier <rolandd@cisco.com>,
	Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:59389 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZBCWNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 17:13:38 -0500
In-Reply-To: <200902030112.n131CNiq010549@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> This patch was dropped because other changes were merged, which wrecked this patch.

The kconfig just moved from one file to another one.  The problem is still there.

---
From: Randy Dunlap <randy.dunlap@oracle.com>

Fix sunrpc/rdma build dependencies.
Survives 12 build combinations of INET, IPV6, SUNRPC,
INFINIBAND, and INFINIBAND_ADDR_TRANS.

ERROR: "rdma_destroy_id" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_connect" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_destroy_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_create_id" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_create_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_resolve_route" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_disconnect" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_resolve_addr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_accept" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_destroy_id" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_listen" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_create_id" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_create_qp" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_bind_addr" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!
ERROR: "rdma_disconnect" [net/sunrpc/xprtrdma/svcrdma.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
cc:	J. Bruce Fields <bfields@fieldses.org>
cc:	Neil Brown <neilb@suse.de>
cc:	Roland Dreier <rolandd@cisco.com>
cc:	Dave Miller <davem@davemloft.net>
---
 net/sunrpc/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm-2009-0202-1712.orig/net/sunrpc/Kconfig
+++ mmotm-2009-0202-1712/net/sunrpc/Kconfig
@@ -6,7 +6,7 @@ config SUNRPC_GSS
 
 config SUNRPC_XPRT_RDMA
 	tristate
-	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
+	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS && EXPERIMENTAL
 	default SUNRPC && INFINIBAND
 	help
 	  This option allows the NFS client and server to support
