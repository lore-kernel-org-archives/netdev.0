From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 16/27] e1000e: 82571-based mezzanine card can fail ethtool link test
Date: Fri, 10 Dec 2010 02:03:23 -0800
Message-ID: <1291975414-30487-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:44216 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052Ab0LJKEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:04:00 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On certain 82571-based mezzanine NICs in some blade servers, the ethtool
link test can fail due to the serdes_has_link flag not set correctly.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 9333921..6942e2f 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1523,8 +1523,10 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				    e1000_serdes_link_autoneg_progress;
 				mac->serdes_has_link = false;
 				e_dbg("AN_UP     -> AN_PROG\n");
+			} else {
+				mac->serdes_has_link = true;
 			}
-		break;
+			break;
 
 		case e1000_serdes_link_forced_up:
 			/*
@@ -1543,6 +1545,8 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 				    e1000_serdes_link_autoneg_progress;
 				mac->serdes_has_link = false;
 				e_dbg("FORCED_UP -> AN_PROG\n");
+			} else {
+				mac->serdes_has_link = true;
 			}
 			break;
 
@@ -1598,6 +1602,7 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 			ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 			mac->serdes_link_state =
 			    e1000_serdes_link_autoneg_progress;
+			mac->serdes_has_link = false;
 			e_dbg("DOWN      -> AN_PROG\n");
 			break;
 		}
-- 
1.7.3.2

