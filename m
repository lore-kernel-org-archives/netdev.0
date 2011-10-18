From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH] tproxy: copy transparent flag when creating a time wait
Date: Tue, 18 Oct 2011 22:17:35 +0200
Message-ID: <1318969055.2959.7.camel@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The transparent socket option setting was not copied to the time wait
socket when an inet socket was being replaced by a time wait socket. This
broke the --transparent option of the socket match and may have caused
that FIN packets belonging to sockets in FIN_WAIT2 or TIME_WAIT state
were being dropped by the packet filter.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 net/ipv4/tcp_minisocks.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index d2fe4e0..0ce3d06 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -328,6 +328,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
                struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
                const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);

+               tw->tw_transparent      = inet_sk(sk)->transparent;
                tw->tw_rcv_wscale       = tp->rx_opt.rcv_wscale;
                tcptw->tw_rcv_nxt       = tp->rcv_nxt;
                tcptw->tw_snd_nxt       = tp->snd_nxt;
-- 
1.7.7



