From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] remove unused variables in net/sunrpc/auth.c
Date: Mon, 10 Jan 2005 22:50:34 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0501102239000.2987@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
        Olaf Kirch <okir@monad.swb.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel <linux-kernel@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We have a few unused variables in net/sunrpc/auth.c:320:

net/sunrpc/auth.c:320: warning: unused variable `auth'
net/sunrpc/auth.c:333: warning: unused variable `auth'
net/sunrpc/auth.c:345: warning: unused variable `auth'
net/sunrpc/auth.c:385: warning: unused variable `auth'

As far as I can see, the patch that caused them to become unused is this 
one (which btw is ~36 months old) :
http://linux.bkbits.net:8080/linux-2.6/diffs/net/sunrpc/auth.c@1.4?nav=index.html|src/|src/net|src/net/sunrpc|hist/net/sunrpc/auth.c

Here is a patch to get rid of them (compile tested only).


Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

diff -up linux-2.6.10-bk13-orig/net/sunrpc/auth.c linux-2.6.10-bk13/net/sunrpc/auth.c
--- linux-2.6.10-bk13-orig/net/sunrpc/auth.c	2005-01-10 22:09:22.000000000 +0100
+++ linux-2.6.10-bk13/net/sunrpc/auth.c	2005-01-10 22:37:55.000000000 +0100
@@ -317,7 +317,6 @@ put_rpccred(struct rpc_cred *cred)
 void
 rpcauth_unbindcred(struct rpc_task *task)
 {
-	struct rpc_auth	*auth = task->tk_auth;
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
 	dprintk("RPC: %4d releasing %s cred %p\n",
@@ -330,7 +329,6 @@ rpcauth_unbindcred(struct rpc_task *task
 u32 *
 rpcauth_marshcred(struct rpc_task *task, u32 *p)
 {
-	struct rpc_auth	*auth = task->tk_auth;
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
 	dprintk("RPC: %4d marshaling %s cred %p\n",
@@ -342,7 +340,6 @@ rpcauth_marshcred(struct rpc_task *task,
 u32 *
 rpcauth_checkverf(struct rpc_task *task, u32 *p)
 {
-	struct rpc_auth	*auth = task->tk_auth;
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
 	dprintk("RPC: %4d validating %s cred %p\n",
@@ -382,7 +379,6 @@ rpcauth_unwrap_resp(struct rpc_task *tas
 int
 rpcauth_refreshcred(struct rpc_task *task)
 {
-	struct rpc_auth	*auth = task->tk_auth;
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
 	dprintk("RPC: %4d refreshing %s cred %p\n",




PS. please keep me on CC 
