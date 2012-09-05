From: Nikolay Aleksandrov <naleksan@redhat.com>
Subject: [PATCH] net: add unknown state to sysfs NIC duplex export
Date: Wed,  5 Sep 2012 16:11:28 +0200
Message-ID: <1346854288-6380-1-git-send-email-naleksan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab2IEOMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 10:12:47 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q85ECl90017071
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2012 10:12:47 -0400
Received: from dhcp-1-132.brq.redhat.com (dhcp-1-132.brq.redhat.com [10.34.1.132])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q85ECkEI020709
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2012 10:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Currently when the NIC duplex state is DUPLEX_UNKNOWN it is exported as
 full through sysfs, this patch adds support for DUPLEX_UNKNOWN. It is
 handled the same way as in ethtool.

 Signed-off-by: Nikolay Aleksandrov <naleksan@redhat.com>
---
 net/core/net-sysfs.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7260717..7720fb1 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -166,9 +166,21 @@ static ssize_t show_duplex(struct device *dev,
 
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
-		if (!__ethtool_get_settings(netdev, &cmd))
-			ret = sprintf(buf, "%s\n",
-				      cmd.duplex ? "full" : "half");
+		if (!__ethtool_get_settings(netdev, &cmd)) {
+			char *duplex;
+			switch(cmd.duplex) {
+			case DUPLEX_HALF:
+				duplex = "half";
+				break;
+			case DUPLEX_FULL:
+				duplex = "full";
+				break;
+			default:
+				duplex = "unknown";
+				break;
+			}
+			ret = sprintf(buf, "%s\n", duplex);
+		}
 	}
 	rtnl_unlock();
 	return ret;
-- 
1.7.11.4
