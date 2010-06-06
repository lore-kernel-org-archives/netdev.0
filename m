From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/10] tg3: 5717: Allow serdes link via
 parallel detect
Date: Sat, 5 Jun 2010 20:24:35 -0700
Message-ID: <1275794679-11085-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4673 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933980Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 serdes phy brings link up via parallel detection without any
additional help from the driver.  This patch changes the
tg3_setup_fiber_mii_phy() function to detect and allow the use of this
feature.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d169337..2dcde13 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4206,6 +4206,8 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
+			} else if (!(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+				/* Link is up via parallel detect */
 			} else {
 				current_link_up = 0;
 			}
@@ -8531,8 +8533,10 @@ static void tg3_timer(unsigned long __opaque)
 				}
 				tg3_setup_phy(tp, 0);
 			}
-		} else if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
+		} else if ((tp->tg3_flags2 & TG3_FLG2_MII_SERDES) &&
+			   !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 			tg3_serdes_parallel_detect(tp);
+		}
 
 		tp->timer_counter = tp->timer_multiplier;
 	}
-- 
1.6.4.4


