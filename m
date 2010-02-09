From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 3/7] be2net: bug fix in be_change_mtu
Date: Tue, 9 Feb 2010 17:02:43 +0530
Message-ID: <20100209113233.GA10485@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:64054 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab0BILcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:32:50 -0500
Received: by iwn12 with SMTP id 12so8475673iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:32:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code allows the new mtu to cross the supported value.
This patch fixes the boundary checks.

From: Suresh R <sureshr@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 1d773db..f1136a3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -473,10 +473,12 @@ static int be_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	if (new_mtu < BE_MIN_MTU ||
-			new_mtu > BE_MAX_JUMBO_FRAME_SIZE) {
+			new_mtu > (BE_MAX_JUMBO_FRAME_SIZE -
+					(ETH_HLEN + ETH_FCS_LEN))) {
 		dev_info(&adapter->pdev->dev,
 			"MTU must be between %d and %d bytes\n",
-			BE_MIN_MTU, BE_MAX_JUMBO_FRAME_SIZE);
+			BE_MIN_MTU,
+			(BE_MAX_JUMBO_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN)));
 		return -EINVAL;
 	}
 	dev_info(&adapter->pdev->dev, "MTU changed from %d to %d bytes\n",
-- 
1.6.3.3

