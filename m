From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] bonding: check nla_put_be32 return value
Date: Sat,  6 May 2017 11:17:06 +0800
Message-ID: <1494040626-13862-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36192 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932945AbdEFDRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 23:17:33 -0400
Received: by mail-pf0-f195.google.com with SMTP id v14so2733802pfd.3
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 20:17:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 drivers/net/bonding/bond_netlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index c502c13..47a8103 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -549,7 +549,8 @@ static int bond_fill_info(struct sk_buff *skb,
 	targets_added = 0;
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 		if (bond->params.arp_targets[i]) {
-			nla_put_be32(skb, i, bond->params.arp_targets[i]);
+			if (nla_put_be32(skb, i, bond->params.arp_targets[i]))
+				goto nla_put_failure;
 			targets_added = 1;
 		}
 	}
-- 
2.5.5
