From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: Remove stale comments referencing timer
Date: Wed, 26 Jul 2017 12:05:38 -0700
Message-ID: <20170726190538.27674-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, slash.tmp@free.fr,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37585 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdGZTFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 15:05:47 -0400
Received: by mail-wr0-f193.google.com with SMTP id 12so14767356wrb.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 12:05:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a390d1f379cf ("phylib: convert state_queue work to
delayed_work"), the PHYLIB state machine was converted to use delayed
workqueues, yet some functions were still referencing the PHY library
timer in their comments, fix that and remove the now unused
linux/timer.h include.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..ac1dcf0289fa 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -30,7 +30,6 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/phy_led_triggers.h>
-#include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mdio.h>
 #include <linux/io.h>
@@ -705,8 +704,8 @@ EXPORT_SYMBOL(phy_start_aneg);
  *
  * Description: The PHY infrastructure can run a state machine
  *   which tracks whether the PHY is starting up, negotiating,
- *   etc.  This function starts the timer which tracks the state
- *   of the PHY.  If you want to maintain your own state machine,
+ *   etc.  This function starts the delayed workqueue which tracks
+ *   the state of the PHY. If you want to maintain your own state machine,
  *   do not call this function.
  */
 void phy_start_machine(struct phy_device *phydev)
@@ -737,9 +736,9 @@ void phy_trigger_machine(struct phy_device *phydev, bool sync)
  * phy_stop_machine - stop the PHY state machine tracking
  * @phydev: target phy_device struct
  *
- * Description: Stops the state machine timer, sets the state to UP
- *   (unless it wasn't up yet). This function must be called BEFORE
- *   phy_detach.
+ * Description: Stops the state machine delayed workqueue, sets the
+ *   state to UP (unless it wasn't up yet). This function must be
+ *   called BEFORE phy_detach.
  */
 void phy_stop_machine(struct phy_device *phydev)
 {
-- 
2.9.3
