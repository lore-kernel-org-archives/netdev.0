From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bonding: allow all slave speeds
Date: Wed,  1 Jun 2011 22:36:33 +0200
Message-ID: <1306960593-16347-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab1FAUgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 16:36:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to check for 10, 100, 1000, 10000 explicitly. Just make this
generic and check for invalid values only (similar check is in ethtool
userspace app). This enables correct speed handling for slave devices
with "nonstandard" speeds.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17b4dd9..716c852 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -629,15 +629,8 @@ static int bond_update_speed_duplex(struct slave *slave)
 		return -1;
 
 	slave_speed = ethtool_cmd_speed(&etool);
-	switch (slave_speed) {
-	case SPEED_10:
-	case SPEED_100:
-	case SPEED_1000:
-	case SPEED_10000:
-		break;
-	default:
+	if (slave_speed == 0 || slave_speed == ((__u32) -1))
 		return -1;
-	}
 
 	switch (etool.duplex) {
 	case DUPLEX_FULL:
-- 
1.7.4.4

