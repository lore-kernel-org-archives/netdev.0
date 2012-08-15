From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 09/14] l2tp: fix info leak via getsockname()
Date: Wed, 15 Aug 2012 23:31:52 +0200
Message-ID: <1345066317-22512-10-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	James Chapman <jchapman@katalix.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The L2TP code for IPv6 fails to initialize the l2tp_unused member of
struct sockaddr_l2tpip6 and that for leaks two bytes kernel stack via
the getsockname() syscall. Initialize l2tp_unused with 0 to avoid the
info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip6.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 35e1e4b..9275471 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -410,6 +410,7 @@ static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
 	lsa->l2tp_family = AF_INET6;
 	lsa->l2tp_flowinfo = 0;
 	lsa->l2tp_scope_id = 0;
+	lsa->l2tp_unused = 0;
 	if (peer) {
 		if (!lsk->peer_conn_id)
 			return -ENOTCONN;
-- 
1.7.10.4
