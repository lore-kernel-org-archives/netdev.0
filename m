From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 09/23] e1000: allow ethtool to pass arbitrary speed advertisment
Date: Tue, 19 Sep 2006 10:28:52 -0700
Message-ID: <20060919172852.4605.18129.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:18445 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030344AbWISRT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:19:58 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With a patch, ethtool can now signify the driver to advertise more
than just a single speed/duplex setting. This allows you to tell the
card to advertise in 10/100 in any speed if you don't have a gigabit
switch for instance.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 0d329d6..d8b9c3f 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -211,13 +211,9 @@ e1000_set_settings(struct net_device *ne
 				     ADVERTISED_FIBRE |
 				     ADVERTISED_Autoneg;
 		else
-			hw->autoneg_advertised = ADVERTISED_10baseT_Half |
-						  ADVERTISED_10baseT_Full |
-						  ADVERTISED_100baseT_Half |
-						  ADVERTISED_100baseT_Full |
-						  ADVERTISED_1000baseT_Full|
-						  ADVERTISED_Autoneg |
-						  ADVERTISED_TP;
+			hw->autoneg_advertised = ecmd->advertising |
+			                         ADVERTISED_TP |
+			                         ADVERTISED_Autoneg;
 		ecmd->advertising = hw->autoneg_advertised;
 	} else
 		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {



---
Auke Kok <auke-jan.h.kok@intel.com>
