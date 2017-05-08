From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] ip6_tunnel: remove unreachable ICMP_REDIRECT code
Date: Mon,  8 May 2017 19:11:03 +0800
Message-ID: <1494241863-32549-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32862 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdEHLLi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:11:38 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so10148903pgc.0
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:11:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After call ip6_tnl_err(), the rel_type will be ether ICMPV6_DEST_UNREACH
or ICMPV6_PKT_TOOBIG. We will never reach ICMP_REDIRECT. So remove it.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/ip6_tunnel.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6eb2ae5..16f8d42 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -591,9 +591,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_type = ICMP_DEST_UNREACH;
 		rel_code = ICMP_FRAG_NEEDED;
 		break;
-	case NDISC_REDIRECT:
-		rel_type = ICMP_REDIRECT;
-		rel_code = ICMP_REDIR_HOST;
 	default:
 		return 0;
 	}
@@ -652,8 +649,6 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		skb_dst(skb2)->ops->update_pmtu(skb_dst(skb2), NULL, skb2, rel_info);
 	}
-	if (rel_type == ICMP_REDIRECT)
-		skb_dst(skb2)->ops->redirect(skb_dst(skb2), NULL, skb2);
 
 	icmp_send(skb2, rel_type, rel_code, htonl(rel_info));
 
-- 
2.5.5
