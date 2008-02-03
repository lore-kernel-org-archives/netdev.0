From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH 8/8] kernel-doc: fix sunrpc warnings
Date: Sun, 3 Feb 2008 15:07:00 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0802031452550.3021@shark.he.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:36065 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755385AbYBCXHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2008 18:07:04 -0500
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 3 Feb 2008 15:07:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Use updated file list for docbook files and
fix kernel-doc warnings in sunrpc:
Warning(linux-2.6.24-git12//net/sunrpc/rpc_pipe.c:689): No description found for parameter 'rpc_client'
Warning(linux-2.6.24-git12//net/sunrpc/rpc_pipe.c:765): No description found for parameter 'flags'
Warning(linux-2.6.24-git12//net/sunrpc/clnt.c:584): No description found for parameter 'tk_ops'
Warning(linux-2.6.24-git12//net/sunrpc/clnt.c:618): No description found for parameter 'bufsize'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
  Documentation/DocBook/kernel-api.tmpl |    8 +++++++-
  net/sunrpc/clnt.c                     |   10 +++++-----
  net/sunrpc/rpc_pipe.c                 |    3 ++-
  net/sunrpc/xprt.c                     |    2 +-
  4 files changed, 15 insertions(+), 8 deletions(-)

--- linux-2.6.24-git12.orig/Documentation/DocBook/kernel-api.tmpl
+++ linux-2.6.24-git12/Documentation/DocBook/kernel-api.tmpl
@@ -230,8 +230,14 @@ X!Ilib/string.c
  !Dnet/sunrpc/sunrpc_syms.c
  -->
  !Enet/sunrpc/xdr.c
-!Enet/sunrpc/svcsock.c
+!Enet/sunrpc/svc_xprt.c
+!Enet/sunrpc/xprt.c
  !Enet/sunrpc/sched.c
+!Enet/sunrpc/socklib.c
+!Enet/sunrpc/stats.c
+!Enet/sunrpc/rpc_pipe.c
+!Enet/sunrpc/rpcb_clnt.c
+!Enet/sunrpc/clnt.c
       </sect1>
    </chapter>

--- linux-2.6.24-git12.orig/net/sunrpc/clnt.c
+++ linux-2.6.24-git12/net/sunrpc/clnt.c
@@ -464,9 +464,9 @@ rpc_release_client(struct rpc_clnt *clnt

  /**
   * rpc_bind_new_program - bind a new RPC program to an existing client
- * @old - old rpc_client
- * @program - rpc program to set
- * @vers - rpc program version
+ * @old: old rpc_client
+ * @program: rpc program to set
+ * @vers: rpc program version
   *
   * Clones the rpc client and sets up a new RPC program. This is mainly
   * of use for enabling different RPC programs to share the same transport.
@@ -575,7 +575,7 @@ EXPORT_SYMBOL_GPL(rpc_call_sync);
   * @clnt: pointer to RPC client
   * @msg: RPC call parameters
   * @flags: RPC call flags
- * @ops: RPC call ops
+ * @tk_ops: RPC call ops
   * @data: user call data
   */
  int
@@ -610,7 +610,7 @@ EXPORT_SYMBOL_GPL(rpc_call_start);
   * rpc_peeraddr - extract remote peer address from clnt's xprt
   * @clnt: RPC client structure
   * @buf: target buffer
- * @size: length of target buffer
+ * @bufsize: length of target buffer
   *
   * Returns the number of bytes that are actually in the stored address.
   */
--- linux-2.6.24-git12.orig/net/sunrpc/xprt.c
+++ linux-2.6.24-git12/net/sunrpc/xprt.c
@@ -124,7 +124,7 @@ EXPORT_SYMBOL_GPL(xprt_register_transpor

  /**
   * xprt_unregister_transport - unregister a transport implementation
- * transport: transport to unregister
+ * @transport: transport to unregister
   *
   * Returns:
   * 0:		transport successfully unregistered
--- linux-2.6.24-git12.orig/net/sunrpc/rpc_pipe.c
+++ linux-2.6.24-git12/net/sunrpc/rpc_pipe.c
@@ -677,7 +677,7 @@ rpc_lookup_negative(char *path, struct n
  /**
   * rpc_mkdir - Create a new directory in rpc_pipefs
   * @path: path from the rpc_pipefs root to the new directory
- * @rpc_clnt: rpc client to associate with this directory
+ * @rpc_client: rpc client to associate with this directory
   *
   * This creates a directory at the given @path associated with
   * @rpc_clnt, which will contain a file named "info" with some basic
@@ -748,6 +748,7 @@ rpc_rmdir(struct dentry *dentry)
   * @private: private data to associate with the pipe, for the caller's use
   * @ops: operations defining the behavior of the pipe: upcall, downcall,
   *	release_pipe, and destroy_msg.
+ * @flags: rpc_inode flags
   *
   * Data is made available for userspace to read by calls to
   * rpc_queue_upcall().  The actual reads will result in calls to
