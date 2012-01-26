From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 5/5] NFS: pass transport net to rpc_pton() while parse server
 name
Date: Thu, 26 Jan 2012 15:12:05 +0400
Message-ID: <20120126111205.8386.64056.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbottomley@parallels.com, bfields@fieldses.org,
	davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/nfs4namespace.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 48a9acd..667ea74 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -97,11 +97,11 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 		struct sockaddr *sa, size_t salen, struct nfs_server *server)
 {
 	ssize_t ret;
+	struct net *net = server->client->cl_xprt->xprt_net;
 
-	ret = rpc_pton(&init_net, string, len, sa, salen);
+	ret = rpc_pton(net, string, len, sa, salen);
 	if (ret == 0) {
-		ret = nfs_dns_resolve_name(server->client->cl_xprt->xprt_net,
-					   string, len, sa, salen);
+		ret = nfs_dns_resolve_name(net, string, len, sa, salen);
 		if (ret < 0)
 			ret = 0;
 	}
