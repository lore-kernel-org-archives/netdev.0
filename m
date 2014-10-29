From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv6: remove assignment in if condition
Date: Wed, 29 Oct 2014 12:57:51 +0100
Message-ID: <1414583871-14196-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do assignment before if condition and test !skb like in rawv6_recvmsg()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/raw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 896af88..075a0fb 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -548,7 +548,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	if (!rp->checksum)
 		goto send;
 
-	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
+	skb = skb_peek(&sk->sk_write_queue);
+	if (!skb)
 		goto out;
 
 	offset = rp->offset;
-- 
1.9.3
