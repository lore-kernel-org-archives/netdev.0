From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] vit: check nla_put_* return value
Date: Mon,  8 May 2017 14:36:20 +0800
Message-ID: <1494225380-12322-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35705 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdEHGgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 02:36:50 -0400
Received: by mail-pg0-f66.google.com with SMTP id i63so9243457pgd.2
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 23:36:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv4/ip_vti.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4097741..4ec9aff 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -546,12 +546,13 @@ static int vti_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm *p = &t->parms;
 
-	nla_put_u32(skb, IFLA_VTI_LINK, p->link);
-	nla_put_be32(skb, IFLA_VTI_IKEY, p->i_key);
-	nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key);
-	nla_put_in_addr(skb, IFLA_VTI_LOCAL, p->iph.saddr);
-	nla_put_in_addr(skb, IFLA_VTI_REMOTE, p->iph.daddr);
-	nla_put_u32(skb, IFLA_VTI_FWMARK, t->fwmark);
+	if (nla_put_u32(skb, IFLA_VTI_LINK, p->link) ||
+	    nla_put_be32(skb, IFLA_VTI_IKEY, p->i_key) ||
+	    nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key) ||
+	    nla_put_in_addr(skb, IFLA_VTI_LOCAL, p->iph.saddr) ||
+	    nla_put_in_addr(skb, IFLA_VTI_REMOTE, p->iph.daddr) ||
+	    nla_put_u32(skb, IFLA_VTI_FWMARK, t->fwmark))
+		return -EMSGSIZE;
 
 	return 0;
 }
-- 
2.5.5
