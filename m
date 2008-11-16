From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] b44: Disable device on shutdown
Date: Sun, 16 Nov 2008 15:39:55 +0100
Message-ID: <200811161539.55557.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pantelis Koukousoulas <pktoss@gmail.com>,
	Gary Zambrano <zambrano@broadcom.com>, stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:49862 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbYKPP0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 10:26:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the SSB core on device shutdown.
This has two advantages:
1) A clean device shutdown is always desired here, because we disable
   the device's global crystal in the next statement.
2) This fixes a bug where the device will come up with the enable-bit
   set on the next initialization (without a reboot inbetween).
   This causes breakage on the second initialization due to code that
   checks this bit (ssb_device_is_enabled() checks).

Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: stable@kernel.org

---

I think this should go in for 2.6.28, as it fixes a
device-doesn't-work-anymore bug after a insmod-rmmod-insmod cycle.

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c	2008-11-16 14:45:08.000000000 +0100
+++ wireless-testing/drivers/net/b44.c	2008-11-16 14:47:06.000000000 +0100
@@ -2233,6 +2233,7 @@ static void __devexit b44_remove_one(str
 	struct net_device *dev = ssb_get_drvdata(sdev);
 
 	unregister_netdev(dev);
+	ssb_device_disable(sdev, 0);
 	ssb_bus_may_powerdown(sdev->bus);
 	free_netdev(dev);
 	ssb_pcihost_set_power_state(sdev, PCI_D3hot);

-- 
Greetings Michael.
