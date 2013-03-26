From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] VXLAN: Fix sparse warnings.
Date: Tue, 26 Mar 2013 11:29:30 -0700
Message-ID: <1364322570-27179-1-git-send-email-pshelar@nicira.com>
Cc: davem@davemloft.net, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:35445 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754057Ab3CZS3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 14:29:36 -0400
Received: by mail-pd0-f198.google.com with SMTP id 4so6798115pdd.5
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 11:29:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes following warning:-
drivers/net/vxlan.c:471:35: warning: symbol 'dev' shadows an earlier one
drivers/net/vxlan.c:433:26: originally declared here
drivers/net/vxlan.c:794:34: warning: symbol 'vxlan' shadows an earlier one
drivers/net/vxlan.c:757:26: originally declared here

CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7624ab1..62a4438 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -468,15 +468,15 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		vni = vxlan->vni;
 
 	if (tb[NDA_IFINDEX]) {
-		struct net_device *dev;
+		struct net_device *tdev;
 
 		if (nla_len(tb[NDA_IFINDEX]) != sizeof(u32))
 			return -EINVAL;
 		ifindex = nla_get_u32(tb[NDA_IFINDEX]);
-		dev = dev_get_by_index(net, ifindex);
-		if (!dev)
+		tdev = dev_get_by_index(net, ifindex);
+		if (!tdev)
 			return -EADDRNOTAVAIL;
-		dev_put(dev);
+		dev_put(tdev);
 	} else
 		ifindex = 0;
 
@@ -792,7 +792,6 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 	n = neigh_lookup(&arp_tbl, &tip, dev);
 
 	if (n) {
-		struct vxlan_dev *vxlan = netdev_priv(dev);
 		struct vxlan_fdb *f;
 		struct sk_buff	*reply;
 
-- 
1.7.1
