From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 4/8] net/sunrpc: Remove uses of NIPQUAD, use %pI4
Date: Tue,  5 Jan 2010 17:20:16 -0800
Message-ID: <b39f7936e8b262c3367ab708bf1e039db53509d3.1262726222.git.joe@perches.com>
References: <cover.1262726222.git.joe@perches.com>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1262726222.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/sunrpc/xprtrdma/transport.c |    3 +--
 net/sunrpc/xprtsock.c           |    5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 7018eef..83d339f 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -165,8 +165,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
 
-	(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-				NIPQUAD(sin->sin_addr.s_addr));
+	(void)snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
 	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..86234bc 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -297,12 +297,11 @@ static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
 	switch (sap->sa_family) {
 	case AF_INET:
 		sin = xs_addr_in(xprt);
-		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
-					NIPQUAD(sin->sin_addr.s_addr));
+		snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 		break;
 	case AF_INET6:
 		sin6 = xs_addr_in6(xprt);
-		(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+		snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
 		break;
 	default:
 		BUG();
-- 
1.6.6.rc0.57.gad7a

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
