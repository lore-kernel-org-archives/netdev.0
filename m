From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH] SUNRPC: destroy freshly allocated transport in case of
	sockaddr init error
Date: Thu, 10 Nov 2011 14:33:23 +0300
Message-ID: <20111110103323.14486.24233.stgit@localhost6.localdomain6>
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

Otherwise we will leak xprt structure and struct net reference.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/xprtsock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d7f97ef..2d78d95 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2530,8 +2530,10 @@ static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 		int err;
 		err = xs_init_anyaddr(args->dstaddr->sa_family,
 					(struct sockaddr *)&new->srcaddr);
-		if (err != 0)
+		if (err != 0) {
+			xprt_free(xprt);
 			return ERR_PTR(err);
+		}
 	}
 
 	return xprt;
