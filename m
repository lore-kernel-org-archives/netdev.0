From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH v7 6/7] SUNRPC: remove rpcbind clients creation during service
	registering
Date: Fri, 28 Oct 2011 14:53:52 +0300
Message-ID: <20111028105351.24628.27860.stgit@localhost6.localdomain6>
References: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111028104530.24628.23631.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't need this code since rpcbind clients are creating during RPC service
creation.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index c144b95..115c691 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -431,11 +431,6 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	int error;
-
-	error = rpcb_create_local();
-	if (error)
-		return error;
 
 	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
 			"rpcbind\n", (port ? "" : "un"),
@@ -571,11 +566,7 @@ int rpcb_v4_register(const u32 program, const u32 version,
 	struct rpc_message msg = {
 		.rpc_argp	= &map,
 	};
-	int error;
 
-	error = rpcb_create_local();
-	if (error)
-		return error;
 	if (rpcb_local_clnt4 == NULL)
 		return -EPROTONOSUPPORT;
 
