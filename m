From: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH resend] sunrpc: fix kernel-doc warnings
Date: Sun, 13 May 2012 10:35:40 -0700
Message-ID: <4FAFF0EC.7080504@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>

Fix kernel-doc warnings in sunrpc/rpc_pipe.c and
sunrpc/rpcb_clnt.c:

Warning(net/sunrpc/rpcb_clnt.c:428): No description found for parameter 'net'
Warning(net/sunrpc/rpcb_clnt.c:567): No description found for parameter 'net'

Warning(net/sunrpc/rpc_pipe.c:133): No description found for parameter 'pipe'
Warning(net/sunrpc/rpc_pipe.c:133): Excess function parameter 'inode' description in 'rpc_queue_upcall'
Warning(net/sunrpc/rpc_pipe.c:839): No description found for parameter 'pipe'
Warning(net/sunrpc/rpc_pipe.c:839): Excess function parameter 'ops' description in 'rpc_mkpipe_dentry'
Warning(net/sunrpc/rpc_pipe.c:839): Excess function parameter 'flags' description in 'rpc_mkpipe_dentry'
Warning(net/sunrpc/rpc_pipe.c:949): No description found for parameter 'dentry'
Warning(net/sunrpc/rpc_pipe.c:949): Excess function parameter 'clnt' description in 'rpc_remove_client_dir'

Signed-off-by: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
---
 net/sunrpc/rpc_pipe.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- lnx-34-rc3.orig/net/sunrpc/rpcb_clnt.c
+++ lnx-34-rc3/net/sunrpc/rpcb_clnt.c
@@ -394,6 +394,7 @@ static int rpcb_register_call(struct rpc
 
 /**
  * rpcb_register - set or unset a port registration with the local rpcbind svc
+ * @net: target network namespace
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
  * @prot: transport protocol to register
@@ -521,6 +522,7 @@ static int rpcb_unregister_all_protofami
 
 /**
  * rpcb_v4_register - set or unset a port registration with the local rpcbind
+ * @net: target network namespace
  * @program: RPC program number of service to (un)register
  * @version: RPC version number of service to (un)register
  * @address: address family, IP address, and port to (un)register
--- lnx-34-rc3.orig/net/sunrpc/rpc_pipe.c
+++ lnx-34-rc3/net/sunrpc/rpc_pipe.c
@@ -120,7 +120,7 @@ EXPORT_SYMBOL_GPL(rpc_pipe_generic_upcal
 
 /**
  * rpc_queue_upcall - queue an upcall message to userspace
- * @inode: inode of upcall pipe on which to queue given message
+ * @pipe: upcall pipe on which to queue given message
  * @msg: message to queue
  *
  * Call with an @inode created by rpc_mkpipe() to queue an upcall.
@@ -819,9 +819,7 @@ static int rpc_rmdir_depopulate(struct d
  * @parent: dentry of directory to create new "pipe" in
  * @name: name of pipe
  * @private: private data to associate with the pipe, for the caller's use
- * @ops: operations defining the behavior of the pipe: upcall, downcall,
- *	release_pipe, open_pipe, and destroy_msg.
- * @flags: rpc_pipe flags
+ * @pipe: &rpc_pipe containing input parameters
  *
  * Data is made available for userspace to read by calls to
  * rpc_queue_upcall().  The actual reads will result in calls to
@@ -943,7 +941,7 @@ struct dentry *rpc_create_client_dir(str
 
 /**
  * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
- * @clnt: rpc client
+ * @dentry: dentry for the pipe
  */
 int rpc_remove_client_dir(struct dentry *dentry)
 {
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
