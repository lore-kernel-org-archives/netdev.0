From: Colin King <colin.king@canonical.com>
Subject: [PATCH][netdev-next] gre: remove duplicated assignment of iph
Date: Wed, 23 Aug 2017 12:13:05 +0100
Message-ID: <20170823111305.19185-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

iph is being assigned the same value twice; remove the redundant
second assignment.

Fixes warning:
net/ipv4/ip_gre.c:265:2: warning: Value stored to 'iph' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/ip_gre.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6e8a62289e03..6b3e7c99a3b6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -268,7 +268,6 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	if (unlikely(!pskb_may_pull(skb, len)))
 		return -ENOMEM;
 
-	iph = ip_hdr(skb);
 	ershdr = (struct erspanhdr *)(skb->data + gre_hdr_len);
 
 	/* The original GRE header does not have key field,
-- 
2.14.1
