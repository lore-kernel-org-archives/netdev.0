From: Imre Deak <imre.deak@intel.com>
Subject: [PATCH 09/11] net/sunrpc: take msecs_to_jiffies_min into use
Date: Fri, 10 May 2013 15:13:27 +0300
Message-ID: <1368188011-23661-9-git-send-email-imre.deak@intel.com>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Haggai Eran <haggaie@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Roland Dreier <roland@purestorage.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use msecs_to_jiffies_min instead of open-coding the same.

Signed-off-by: Imre Deak <imre.deak@intel.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 93726560..9cac2c8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -404,7 +404,7 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 		goto out;
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+				msecs_to_jiffies_min(RDMA_RESOLVE_TIMEOUT));
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
@@ -417,7 +417,7 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 		goto out;
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+				msecs_to_jiffies_min(RDMA_RESOLVE_TIMEOUT));
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
-- 
1.7.10.4
