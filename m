From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: net (tg3): Fix failure to enable WoL by default when possible
Date: Mon, 8 Dec 2008 00:46:55 +0100
Message-ID: <200812080046.56119.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35348 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbYLGXrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2008 18:47:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: net (tg3): Fix failure to enable WoL by default when possible

tg3 is supposed to enable WoL by default on adapters which support
that, but it fails to do so unless the adapter's
/sys/devices/.../power/wakeup file contains 'enabled' during the
initialization of the adapter.  Fix that by making tg3 update the
device's 'should_wakeup' bit automatically whenever WoL should be
enabled by default.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/tg3.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -11296,9 +11296,10 @@ static void __devinit tg3_get_eeprom_hw_
 		if (val & VCPU_CFGSHDW_ASPM_DBNC)
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
-		    (val & VCPU_CFGSHDW_WOL_MAGPKT) &&
-		    device_may_wakeup(&tp->pdev->dev))
+		    (val & VCPU_CFGSHDW_WOL_MAGPKT)) {
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+			device_set_wakeup_enable(&tp->pdev->dev, true);
+		}
 		return;
 	}
 
