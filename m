From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 1/4] SUNRPC: rpcbind clients internals virtualization
Date: Tue, 04 Oct 2011 20:58:58 +0300
Message-ID: <20111004165858.6638.76932.stgit@localhost6.localdomain6>
References: <20111004165637.6638.57399.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111004165637.6638.57399.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves static rpcbind internals to sunrpc part of network namespace
context. This will allow to create rcpbind clients per network namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/netns.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index d013bf2..83eede3 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -9,6 +9,11 @@ struct cache_detail;
 struct sunrpc_net {
 	struct proc_dir_entry *proc_net_rpc;
 	struct cache_detail *ip_map_cache;
+
+	struct rpc_clnt *rpcb_local_clnt;
+	struct rpc_clnt *rpcb_local_clnt4;
+	spinlock_t rpcb_clnt_lock;
+	unsigned int rpcb_users;
 };
 
 extern int sunrpc_net_id;
