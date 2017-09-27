From: Hoang Tran <tranviethoang.vn@gmail.com>
Subject: [PATCH net-next] tcp: fix under-evaluated ssthresh in TCP Vegas
Date: Wed, 27 Sep 2017 18:30:58 +0200
Message-ID: <1506529940-2143-1-git-send-email-hoang.tran@uclouvain.be>
Cc: Hoang Tran <hoang.tran@uclouvain.be>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the commit 76174004a0f19785 (tcp: do not slow start when cwnd equals
ssthresh), the comparison to the reduced cwnd in tcp_vegas_ssthresh() would
under-evaluate the ssthresh.

Signed-off-by: Hoang Tran <hoang.tran@uclouvain.be>
---
 net/ipv4/tcp_vegas.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 218cfcc..ee113ff 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -158,7 +158,7 @@ EXPORT_SYMBOL_GPL(tcp_vegas_cwnd_event);
 
 static inline u32 tcp_vegas_ssthresh(struct tcp_sock *tp)
 {
-	return  min(tp->snd_ssthresh, tp->snd_cwnd-1);
+	return  min(tp->snd_ssthresh, tp->snd_cwnd);
 }
 
 static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
-- 
2.7.4
