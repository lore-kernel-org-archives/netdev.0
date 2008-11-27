From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 5/5] e100: cleanup link up/down messages
Date: Wed, 26 Nov 2008 16:03:02 -0800
Message-ID: <20081127000302.22431.22196.stgit@gitlost.lost>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:43567 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752408AbYK0ADP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 19:03:15 -0500
In-Reply-To: <20081127000206.22431.53339.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The system log messages created on a link status change need to follow a
specific format to work with tools some customers use.  This also makes
the messages consistant with other Intel driver link messages.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e100.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 2001a63..dce7ff2 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1580,11 +1580,13 @@ static void e100_watchdog(unsigned long data)
 	mii_ethtool_gset(&nic->mii, &cmd);
 
 	if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link up, %sMbps, %s-duplex\n",
-			cmd.speed == SPEED_100 ? "100" : "10",
-			cmd.duplex == DUPLEX_FULL ? "full" : "half");
+		printk(KERN_INFO "e100: %s NIC Link is Up %s Mbps %s Duplex\n",
+		       nic->netdev->name,
+		       cmd.speed == SPEED_100 ? "100" : "10",
+		       cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
 	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
-		DPRINTK(LINK, INFO, "link down\n");
+		printk(KERN_INFO "e100: %s NIC Link is Down\n",
+		       nic->netdev->name);
 	}
 
 	mii_check_link(&nic->mii);

