From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 3/5] sunrpc: Use rcu_barrier() on unload.
Date: Fri, 26 Jun 2009 22:45:58 +0200
Message-ID: <20090626204558.10664.22621.stgit@localhost>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34395 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444AbZFZUp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:45:56 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sunrpc module uses rcu_call() thus it should use rcu_barrier() on
module unload.

Have not verified that the possibility for new call_rcu() callbacks
has been disabled.  As a hint for checking, the functions calling
call_rcu() (unx_destroy_cred and generic_destroy_cred) are
registered as crdestroy function pointer in struct rpc_credops.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/sunrpc/sunrpc_syms.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 843629f..adaa819 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -66,6 +66,7 @@ cleanup_sunrpc(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_exit();
 #endif
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 MODULE_LICENSE("GPL");
 module_init(init_sunrpc);

