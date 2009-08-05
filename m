From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/2] net/rds: Use AF_INET for sin_family field
Date: Wed, 5 Aug 2009 14:34:34 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908051434110.20453@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "David S. Miller" <davem@davemloft.net>,
	Andy Grover <andy.grover@oracle.com>, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934255AbZHEMeq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Elsewhere the sin_family field holds a value with a name of the form
AF_..., so it seems reasonable to do so here as well.  Also the values of
PF_INET and AF_INET are the same.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
struct sockaddr_in sip;
@@

(
sip.sin_family ==
- PF_INET
+ AF_INET
|
sip.sin_family !=
- PF_INET
+ AF_INET
|
sip.sin_family =
- PF_INET
+ AF_INET
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/rds/rdma_transport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -137,7 +137,7 @@ static int __init rds_rdma_listen_init(v
 		goto out;
 	}
 
-	sin.sin_family = PF_INET,
+	sin.sin_family = AF_INET,
 	sin.sin_addr.s_addr = (__force u32)htonl(INADDR_ANY);
 	sin.sin_port = (__force u16)htons(RDS_PORT);
 
