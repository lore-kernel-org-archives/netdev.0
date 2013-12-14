From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bondnl: use be32 nla put/get for be32 values
Date: Sat, 14 Dec 2013 12:32:10 +0100
Message-ID: <1387020730-28211-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:48483 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab3LNLcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 06:32:14 -0500
Received: by mail-ea0-f180.google.com with SMTP id f15so1326936eak.11
        for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 03:32:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index d7d84db..990793d 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -125,7 +125,7 @@ static int bond_changelink(struct net_device *bond_dev,
 		int i = 0, rem;
 
 		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
-			__be32 target = nla_get_u32(attr);
+			__be32 target = nla_get_be32(attr);
 			targets[i++] = target;
 		}
 
@@ -224,7 +224,7 @@ static int bond_fill_info(struct sk_buff *skb,
 	targets_added = 0;
 	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 		if (bond->params.arp_targets[i]) {
-			nla_put_u32(skb, i, bond->params.arp_targets[i]);
+			nla_put_be32(skb, i, bond->params.arp_targets[i]);
 			targets_added = 1;
 		}
 	}
-- 
1.8.3.1
