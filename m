From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/3] e1000: allow ethtool to see link status when down
Date: Fri, 16 Feb 2007 14:39:30 -0800
Message-ID: <20070216223930.26963.23255.stgit@gitlost.site>
References: <20070216223913.26963.76602.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Garzik, Jeff" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1357 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1946161AbXBPWZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 17:25:13 -0500
In-Reply-To: <20070216223913.26963.76602.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


By reading the MAC status register we can detect whether the MAC has
seen the PHY see link. This allows us to show the link properties before
the device is up in ethtool.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 44ebc72..6777887 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -166,7 +166,7 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	if (netif_carrier_ok(adapter->netdev)) {
+	if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU) {
 
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
 		                                   &adapter->link_duplex);



---
Auke Kok <auke-jan.h.kok@intel.com>
