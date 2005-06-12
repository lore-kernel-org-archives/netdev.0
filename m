From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: [PATCH] net: fix sparse warning (plain int as NULL)
Date: Mon, 13 Jun 2005 00:05:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506122358570.16521@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Ross Biro <ross.biro@gmail.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: LKML <linux-kernel@vger.kernel.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here's a patch to fix a small sparse warning in net/ipv4/tcp_input.c :
net/ipv4/tcp_input.c:4179:29: warning: Using plain integer as NULL pointer

Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
---

 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.12-rc6-mm1-orig/net/ipv4/tcp_input.c	2005-06-12 15:58:58.000000000 +0200
+++ linux-2.6.12-rc6-mm1/net/ipv4/tcp_input.c	2005-06-12 23:58:41.000000000 +0200
@@ -4176,7 +4176,7 @@ int tcp_rcv_state_process(struct sock *s
 				 */
 				if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 				    !tp->srtt)
-					tcp_ack_saw_tstamp(tp, 0, 0);
+					tcp_ack_saw_tstamp(tp, NULL, 0);
 
 				if (tp->rx_opt.tstamp_ok)
 					tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;





Please CC me on replies.
