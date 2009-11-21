From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/23] e1000e: check WoL mode is among set of
	supported modes
Date: Sat, 21 Nov 2009 01:22:01 -0800
Message-ID: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:46797
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbZKUJWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:22:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When setting WoL feature, check the supplied modes are all supported rather
than checking for no support.  This way, if any new modes are added the
driver does not default to not complaining about it if we don't really
support it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index c430dc8..3af5ee4 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1777,12 +1777,11 @@ static int e1000_set_wol(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & WAKE_MAGICSECURE)
-		return -EOPNOTSUPP;
-
 	if (!(adapter->flags & FLAG_HAS_WOL) ||
-	    !device_can_wakeup(&adapter->pdev->dev))
-		return wol->wolopts ? -EOPNOTSUPP : 0;
+	    !device_can_wakeup(&adapter->pdev->dev) ||
+	    (wol->wolopts & ~(WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
+	                      WAKE_MAGIC | WAKE_PHY | WAKE_ARP)))
+		return -EOPNOTSUPP;
 
 	/* these settings will always override what we currently have */
 	adapter->wol = 0;

