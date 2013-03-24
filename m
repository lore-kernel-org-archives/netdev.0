From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] ipv4: Fix ip-header identification for gso packets.
Date: Sat, 23 Mar 2013 21:10:48 -0700
Message-ID: <1364098248-1766-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:35950 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750742Ab3CXEL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 00:11:57 -0400
Received: by mail-pd0-f197.google.com with SMTP id 3so4654939pdj.4
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 21:11:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For TCP protocol ip-header id needs to be incremented even if
IP_DF flag is set. This behaviour was changed in commit
490ab08127cebc25e3a26 (IP_GRE: Fix IP-Identification).

Following patch fixes it so that identification is always
incremented for TCP.

Reported-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

---
 net/ipv4/af_inet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e5882c..4958b9d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1334,7 +1334,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				iph->frag_off |= htons(IP_MF);
 			offset += (skb->len - skb->mac_len - iph->ihl * 4);
 		} else  {
-			if (!(iph->frag_off & htons(IP_DF)))
+			if (proto == IPPROTO_TCP || !(iph->frag_off & htons(IP_DF)))
 				iph->id = htons(id++);
 		}
 		iph->tot_len = htons(skb->len - skb->mac_len);
-- 
1.7.1
