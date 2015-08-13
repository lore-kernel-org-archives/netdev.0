From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next] net: addr IFLA_OPERSTATE to netlink message for ipv6 ifinfo
Date: Thu, 13 Aug 2015 15:26:35 -0400
Message-ID: <1439493995-1079-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33667 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbbHMT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 15:28:25 -0400
Received: by ykaz130 with SMTP id z130so50389592yka.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 12:28:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is useful information to include in ipv6 netlink messages that
report interface information.  IFLA_OPERSTATE is already included in
ipv4 messages, but missing for ipv6.  This closes that gap.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 53e3a9d..d119686 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4637,6 +4637,7 @@ static inline size_t inet6_if_nlmsg_size(void)
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
+	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(inet6_ifla6_size()); /* IFLA_PROTINFO */
 }
 
@@ -4893,7 +4894,9 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
 	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
 	    (dev->ifindex != dev_get_iflink(dev) &&
-	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))))
+	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))) ||
+	    nla_put_u8(skb, IFLA_OPERSTATE,
+		       netif_running(dev) ? dev->operstate : IF_OPER_DOWN))
 		goto nla_put_failure;
 	protoinfo = nla_nest_start(skb, IFLA_PROTINFO);
 	if (!protoinfo)
-- 
1.9.3
