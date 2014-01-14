From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v3 3/4] net: make tcp_cleanup_rbuf private
Date: Mon, 13 Jan 2014 16:47:59 -0800
Message-ID: <20140114004719.27138.21488.stgit@viggo.jf.intel.com>
References: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: dmaengine@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_dma was the only external user so this can become local to tcp.c
again.

Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

Since v1: keep the tcp_ prefix.

 include/net/tcp.h |    1 -
 net/ipv4/tcp.c    |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 084c163e9d40..571036b3bead 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -370,7 +370,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct tcphdr *th, unsigned int len);
 void tcp_rcv_space_adjust(struct sock *sk);
-void tcp_cleanup_rbuf(struct sock *sk, int copied);
 int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
 void tcp_twsk_destructor(struct sock *sk);
 ssize_t tcp_splice_read(struct socket *sk, loff_t *ppos,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8dc913dfbaef..10dda80fccc9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1332,7 +1332,7 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
  * calculation of whether or not we must ACK for the sake of
  * a window update.
  */
-void tcp_cleanup_rbuf(struct sock *sk, int copied)
+static void tcp_cleanup_rbuf(struct sock *sk, int copied)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool time_to_ack = false;
