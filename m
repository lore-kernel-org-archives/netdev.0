From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000: fix mispatch for media type detect.
Date: Tue, 18 Apr 2006 12:40:36 -0700
Message-ID: <20060418194035.16262.63448.stgit@gitlost.site>
References: <20060418193950.16262.10757.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:2309 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932293AbWDRTgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 15:36:49 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060418193950.16262.10757.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Recent patch was mismerged in the miitool path. e1000_media_type_copper
was being compared with the phy type instead of the media type.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 82d443b..2b8bced 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4174,7 +4174,7 @@ e1000_mii_ioctl(struct net_device *netde
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
-		if (adapter->hw.phy_type == e1000_media_type_copper) {
+		if (adapter->hw.media_type == e1000_media_type_copper) {
 			switch (data->reg_num) {
 			case PHY_CTRL:
 				if (mii_reg & MII_CR_POWER_DOWN)



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
