From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2][netdev-next] gre: remove duplicated assignment of iph
Date: Wed, 23 Aug 2017 12:59:48 +0100
Message-ID: <20170823115948.19884-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: William Tu <u9012063@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

iph is being assigned the same value twice; remove the redundant
first assignment. (Thanks to Nikolay Aleksandrov for pointing out
that the first asssignment should be removed and not the second)

Fixes warning:
net/ipv4/ip_gre.c:265:2: warning: Value stored to 'iph' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/ip_gre.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e8a62289e03..161326f7f10b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -262,7 +262,6 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	int len;
 
 	itn = net_generic(net, erspan_net_id);
-	iph = ip_hdr(skb);
 	len = gre_hdr_len + sizeof(*ershdr);
 
 	if (unlikely(!pskb_may_pull(skb, len)))
-- 
2.14.1
