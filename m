From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: skip dead but not buried clients on PipeFS events
Date: Thu, 19 Apr 2012 14:57:18 +0400
Message-ID: <20120419105707.32131.79719.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These clients can't be safely dereferenced if their counter in 0.

Signee-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6797246..591994d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -218,7 +218,8 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 		if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 		    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 			continue;
-		atomic_inc(&clnt->cl_count);
+		if (atomic_inc_return(&clnt->cl_count) == 1)
+			continue;
 		spin_unlock(&sn->rpc_client_lock);
 		return clnt;
 	}
