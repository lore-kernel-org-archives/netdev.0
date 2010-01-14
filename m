From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] xprtsock.c: make bc_{malloc/free} static
Date: Thu, 14 Jan 2010 15:38:31 -0700
Message-ID: <201001141538.31496.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bfields@fieldses.org, neilb@suse.de, Trond.Myklebust@netapp.com,
	davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:11735 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932339Ab0ANWib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 17:38:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xprtsock.c: make bc_{malloc/free} static

The server backchannel buf_alloc and buf_free methods should
be static since they are not used outside this file.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..721bafd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2100,7 +2100,7 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
  * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
  * to use the server side send routines.
  */
-void *bc_malloc(struct rpc_task *task, size_t size)
+static void *bc_malloc(struct rpc_task *task, size_t size)
 {
 	struct page *page;
 	struct rpc_buffer *buf;
@@ -2120,7 +2120,7 @@ void *bc_malloc(struct rpc_task *task, size_t size)
 /*
  * Free the space allocated in the bc_alloc routine
  */
-void bc_free(void *buffer)
+static void bc_free(void *buffer)
 {
 	struct rpc_buffer *buf;
 
