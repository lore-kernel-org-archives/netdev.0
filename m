From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: rose: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 13:03:51 -0500
Message-ID: <20171019180351.GA11525@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/rose/rose_in.c    | 1 +
 net/rose/rose_route.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/net/rose/rose_in.c b/net/rose/rose_in.c
index 0a63947..9bbbfe3 100644
--- a/net/rose/rose_in.c
+++ b/net/rose/rose_in.c
@@ -219,6 +219,7 @@ static int rose_state4_machine(struct sock *sk, struct sk_buff *skb, int framety
 	switch (frametype) {
 	case ROSE_RESET_REQUEST:
 		rose_write_internal(sk, ROSE_RESET_CONFIRMATION);
+		/* fall through */
 	case ROSE_RESET_CONFIRMATION:
 		rose_stop_timer(sk);
 		rose_start_idletimer(sk);
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 452bbb3..ac0f733 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -346,6 +346,7 @@ static int rose_del_node(struct rose_route_struct *rose_route,
 				case 0:
 					rose_node->neighbour[0] =
 						rose_node->neighbour[1];
+					/* fall through */
 				case 1:
 					rose_node->neighbour[1] =
 						rose_node->neighbour[2];
@@ -507,6 +508,7 @@ void rose_rt_device_down(struct net_device *dev)
 				switch (i) {
 				case 0:
 					t->neighbour[0] = t->neighbour[1];
+					/* fall through */
 				case 1:
 					t->neighbour[1] = t->neighbour[2];
 				case 2:
-- 
2.7.4
