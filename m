From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: seg6_genl_set_tunsrc() must check kmemdup()
 return value
Date: Fri, 20 Jan 2017 07:57:42 -0800
Message-ID: <1484927862.16328.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Lebrun <david.lebrun@uclouvain.be>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33405 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752373AbdATP6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 10:58:41 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so7229529pgd.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 07:57:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

seg6_genl_get_tunsrc() and set_tun_src() do not handle tun_src being
possibly NULL, so we must check kmemdup() return value and abort if
it is NULL

Fixes: 915d7e5e5930 ("ipv6: sr: add code base for control plane support of SR-IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index b172d85c650a376f541ea05d72046c76b8404303..a855eb325b030a666fe92c56a2d432c77d9dfe7a 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -176,6 +176,8 @@ static int seg6_genl_set_tunsrc(struct sk_buff *skb, struct genl_info *info)
 
 	val = nla_data(info->attrs[SEG6_ATTR_DST]);
 	t_new = kmemdup(val, sizeof(*val), GFP_KERNEL);
+	if (!t_new)
+		return -ENOMEM;
 
 	mutex_lock(&sdata->lock);
 
