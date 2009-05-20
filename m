From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: fix LRO warning
Date: Tue, 19 May 2009 23:16:20 -0700
Message-ID: <20090520061619.13507.27784.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:58647 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751009AbZETGQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb supports LRO, but was not setting any hooks to the ->set_flags
ethtool_ops function.  This would trigger warnings if the user tried
to enable or disable LRO.

Based on the patch provided by Stephen Hemminger <shemminger@vyatta.com>

Reported-by: Sergey Kononenko <sergk@sergk.org.ua>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---

 drivers/net/igb/igb_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 3c831f1..44ceb36 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -2024,6 +2024,10 @@ static struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+	.get_flags              = ethtool_op_get_flags,
+#ifdef CONFIG_IGB_LRO
+	.set_flags              = ethtool_op_set_flags,
+#endif
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)

