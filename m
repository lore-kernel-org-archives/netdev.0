From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] bcm43xx_d80211: Fix major memory corruption bug
Date: Sun, 21 Jan 2007 00:27:40 -0500
Message-ID: <20070121052740.7299.29574.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:37761 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbXAUF1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 00:27:43 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H8VEG-0006JR-6u
	for netdev@vger.kernel.org; Sun, 21 Jan 2007 00:26:56 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set phy->lo_control to NULL whenever it's freed.  Failure to do so leads
to zeroing a block of memory that uses to hold *phy->lo_control, which
caused random crashes down the road.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 3064322..62d4dc9 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3048,6 +3048,7 @@ static void bcm43xx_wireless_core_exit(struct bcm43xx_wldev *dev)
 	if (phy->dyn_tssi_tbl)
 		kfree(phy->tssi2dbm);
 	kfree(phy->lo_control);
+	phy->lo_control = NULL;
 	ssb_chipco_set_clockmode(chipco, SSB_CLKMODE_SLOW);
 	bcm43xx_vstack_free(&dev->genstack);
 	bcm43xx_set_status(dev, BCM43xx_STAT_UNINIT);
@@ -3179,6 +3180,7 @@ err_kfree_tssitbl:
 		kfree(phy->tssi2dbm);
 err_kfree_lo_control:
 	kfree(phy->lo_control);
+	phy->lo_control = NULL;
 err_slowclock:
 	ssb_chipco_set_clockmode(chipco, SSB_CLKMODE_SLOW);
 	bcm43xx_set_status(dev, BCM43xx_STAT_UNINIT);

