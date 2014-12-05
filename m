From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.17 100/122] net/ping: handle protocol mismatching scenario
Date: Fri,  5 Dec 2014 14:44:34 -0800
Message-ID: <20141205223321.034961165@linuxfoundation.org>
References: <20141205223305.514276242@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Jane Zhou <a17711@motorola.com>,
	Yiwei Zhao <gbjc64@motorola.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205223305.514276242@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.17-stable review patch.  If anyone has any objections, please let me know.

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/ipv4/ping.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -217,6 +217,8 @@ static struct sock *ping_lookup(struct n
 					     &ipv6_hdr(skb)->daddr))
 				continue;
 #endif
+		} else {
+			continue;
 		}
 
 		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
