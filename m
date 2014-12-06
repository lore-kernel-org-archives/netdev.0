From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 2/2] rocker: remove swdev mode
Date: Fri,  5 Dec 2014 17:16:44 -0800
Message-ID: <1417828604-42722-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42169 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaLFBQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 20:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This resets rocker mode to zero (vepa) during gets.
This is because the default getlink handler that rocker
uses today always takes a mode.

Will fix that in a subsequent patch.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..391077c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3700,27 +3700,11 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct nlattr *protinfo;
-	struct nlattr *afspec;
 	struct nlattr *attr;
-	u16 mode;
 	int err;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
 				   IFLA_PROTINFO);
-	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
-
-	if (afspec) {
-		attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
-		if (attr) {
-			if (nla_len(attr) < sizeof(mode))
-				return -EINVAL;
-
-			mode = nla_get_u16(attr);
-			if (mode != BRIDGE_MODE_SWDEV)
-				return -EINVAL;
-		}
-	}
-
 	if (protinfo) {
 		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
 		if (attr) {
@@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				      u32 filter_mask)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	u16 mode = BRIDGE_MODE_SWDEV;
+	u16 mode = 0;
 	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
 
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
-- 
1.7.10.4
