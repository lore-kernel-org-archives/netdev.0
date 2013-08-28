From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 13/13] bonding: pr_debug instead of pr_warn in bond_arp_send_all
Date: Wed, 28 Aug 2013 23:25:16 +0200
Message-ID: <1377725116-31126-14-git-send-email-vfalico@redhat.com>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657Ab3H1V0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:26:18 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They're simply annoying and will spam dmesg constantly if we hit them, so
convert to pr_debug so that we still can access them in case of debugging.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2: new patch
    v3: no change
    v4: no change

 drivers/net/bonding/bond_main.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b87ad76..c50679f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2336,10 +2336,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		rt = ip_route_output(dev_net(bond->dev), targets[i], 0,
 				     RTO_ONLINK, 0);
 		if (IS_ERR(rt)) {
-			if (net_ratelimit()) {
-				pr_warning("%s: no route to arp_ip_target %pI4\n",
-					   bond->dev->name, &targets[i]);
-			}
+			pr_debug("%s: no route to arp_ip_target %pI4\n",
+				 bond->dev->name, &targets[i]);
 			continue;
 		}
 
@@ -2386,10 +2384,10 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		rcu_read_unlock();
 
 		/* Not our device - skip */
-		if (net_ratelimit())
-			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
-				   bond->dev->name, &targets[i],
-				   rt->dst.dev ? rt->dst.dev->name : "NULL");
+		pr_debug("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
+			 bond->dev->name, &targets[i],
+			 rt->dst.dev ? rt->dst.dev->name : "NULL");
+
 		ip_rt_put(rt);
 		continue;
 
-- 
1.8.4
