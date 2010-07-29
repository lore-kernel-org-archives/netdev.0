From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 3/4] be2net: change to show correct physical link
 status
Date: Thu, 29 Jul 2010 21:47:17 +0530
Message-ID: <20100729161707.GA15506@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:17310 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754629Ab0G2QRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 12:17:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

link status is wrongly displayed under certain circumstances.
This change fixes it.

Signed-off-by: Somnath K <somnathk@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index c0ade24..cd16243 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -322,10 +322,11 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	int status;
 	u16 intf_type;
 
-	if (adapter->link_speed < 0) {
+	if ((adapter->link_speed < 0) || (!(netdev->flags & IFF_UP))) {
 		status = be_cmd_link_status_query(adapter, &link_up,
 						&mac_speed, &link_speed);
 
+		be_link_status_update(adapter, link_up);
 		/* link_speed is in units of 10 Mbps */
 		if (link_speed) {
 			ecmd->speed = link_speed*10;
-- 
1.7.0.4

