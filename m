From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] rtnetlink: allow to register ops without ops->setup set
Date: Wed, 25 Jun 2014 14:27:59 +0200
Message-ID: <1403699280-12837-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34508 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbaFYM2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:28:10 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so1934197wgg.25
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 05:28:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, it is assumed that ops->setup is filled up. But there might be
case that ops might make sense even without ->setup. In that case,
forbid to newlink and dellink.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1063996..84affd7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1777,7 +1777,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -ENODEV;
 
 	ops = dev->rtnl_link_ops;
-	if (!ops)
+	if (!ops || !ops->setup)
 		return -EOPNOTSUPP;
 
 	ops->dellink(dev, &list_kill);
@@ -2038,6 +2038,9 @@ replay:
 			return -EOPNOTSUPP;
 		}
 
+		if (!ops->setup)
+			return -EOPNOTSUPP;
+
 		if (!ifname[0])
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
 
-- 
1.9.0
