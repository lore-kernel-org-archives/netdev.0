From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.13.y-ckt 60/96] net/ping: handle protocol mismatching scenario
Date: Mon, 15 Dec 2014 11:26:20 -0800
Message-ID: <1418671616-25482-61-git-send-email-kamal@canonical.com>
References: <1418671616-25482-1-git-send-email-kamal@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Jane Zhou <a17711@motorola.com>,
	Yiwei Zhao <gbjc64@motorola.com>,
	Kamal Mostafa <kamal@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418671616-25482-1-git-send-email-kamal@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.13.11-ckt13 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Jane Zhou <a17711@motorola.com>

commit 91a0b603469069cdcce4d572b7525ffc9fd352a6 upstream.

ping_lookup() may return a wrong sock if sk_buff's and sock's protocols
dont' match. For example, sk_buff's protocol is ETH_P_IPV6, but sock's
sk_family is AF_INET, in that case, if sk->sk_bound_dev_if is zero, a wrong
sock will be returned.
the fix is to "continue" the searching, if no matching, return NULL.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Jane Zhou <a17711@motorola.com>
Signed-off-by: Yiwei Zhao <gbjc64@motorola.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 net/ipv4/ping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 3ef2919..8e0f65c 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -213,6 +213,8 @@ static struct sock *ping_lookup(struct net *net, struct sk_buff *skb, u16 ident)
 					     &ipv6_hdr(skb)->daddr))
 				continue;
 #endif
+		} else {
+			continue;
 		}
 
 		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
-- 
1.9.1
