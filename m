From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [RESEND PATCH] ipv4: ip_check_defrag should correctly check return value of skb_copy_bits
Date: Thu, 19 Feb 2015 12:26:32 +0300
Message-ID: <1424337992-8854-1-git-send-email-al.drozdov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	ideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_copy_bits() returns zero on success and a negative value on error,
so it is needed to invert the condition in ip_check_defrag().

Fixes: 1bf3751ec90c ("ipv4: ip_check_defrag must not modify skb before unsharing")
Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Cc: Johannes Berg <johannes.berg@intel.com>
---
 net/ipv4/ip_fragment.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e5b6d0d..2c8d98e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -664,7 +664,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 	if (skb->protocol != htons(ETH_P_IP))
 		return skb;
 
-	if (!skb_copy_bits(skb, 0, &iph, sizeof(iph)))
+	if (skb_copy_bits(skb, 0, &iph, sizeof(iph)) < 0)
 		return skb;
 
 	if (iph.ihl < 5 || iph.version != 4)
-- 
1.9.1
