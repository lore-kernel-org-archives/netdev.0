From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: tipc: mark expected switch fall-throughs
Date: Fri, 20 Oct 2017 12:01:26 -0500
Message-ID: <20171020170126.GA16177@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
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

 net/tipc/bearer.c | 1 +
 net/tipc/link.c   | 3 ++-
 net/tipc/socket.c | 4 ++--
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 47ec121..786dcfd 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -615,6 +615,7 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 	case NETDEV_CHANGE:
 		if (netif_carrier_ok(dev))
 			break;
+		/* fall through */
 	case NETDEV_UP:
 		test_and_set_bit_lock(0, &b->up);
 		break;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 870b9b8..fc1714e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1051,6 +1051,7 @@ static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb,
 			skb_queue_tail(mc_inputq, skb);
 			return true;
 		}
+		/* fall through */
 	case CONN_MANAGER:
 		skb_queue_tail(inputq, skb);
 		return true;
@@ -1463,7 +1464,7 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 		if ((less_eq(msg_session(hdr), l->peer_session)) &&
 		    (l->peer_session != ANY_SESSION))
 			break;
-		/* fall thru' */
+		/* fall through */
 
 	case ACTIVATE_MSG:
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2bbab4f..ce6cd01 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -730,7 +730,7 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	case TIPC_ESTABLISHED:
 		if (!tsk->cong_link_cnt && !tsk_conn_cong(tsk))
 			revents |= POLLOUT;
-		/* fall thru' */
+		/* fall through */
 	case TIPC_LISTEN:
 	case TIPC_CONNECTING:
 		if (skb)
@@ -2341,7 +2341,7 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 		 * case is EINPROGRESS, rather than EALREADY.
 		 */
 		res = -EINPROGRESS;
-		/* fall thru' */
+		/* fall through */
 	case TIPC_CONNECTING:
 		if (!timeout) {
 			if (previous == TIPC_CONNECTING)
-- 
2.7.4
