From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] team: use strlcpy with ethtool_drvinfo fields
Date: Sat,  5 Jan 2013 10:53:10 -0200
Message-ID: <1357390390-16549-1-git-send-email-fbl@redhat.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774Ab3AEMxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2013 07:53:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fields must be null-terminated.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/team/team.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 78c7d87..e27ac5c 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1747,8 +1747,8 @@ static const struct net_device_ops team_netdev_ops = {
 static void team_ethtool_get_drvinfo(struct net_device *dev,
 				     struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, DRV_NAME, 32);
-	strncpy(drvinfo->version, UTS_RELEASE, 32);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, UTS_RELEASE, sizeof(drvinfo->version));
 }
 
 static const struct ethtool_ops team_ethtool_ops = {
-- 
1.8.0.1
