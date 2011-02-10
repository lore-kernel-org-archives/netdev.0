From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/3] atl1c: Do not call device_init_wakeup() in atl1c_probe()
Date: Thu, 10 Feb 2011 17:54:04 +0100
Message-ID: <201102101754.04974.rjw@sisk.pl>
References: <201102101751.56508.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Linux PM mailing list <linux-pm@lists.linux-foundation.org>,
	Thomas Fjellstrom <thomas@fjellstrom.ca>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33485 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820Ab1BJQ4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 11:56:52 -0500
In-Reply-To: <201102101751.56508.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The atl1c driver shouldn't call device_init_wakeup() in its probe
routine with the second argument equal to 1, because for PCI devices
the wakeup capability setting is initialized as appropriate by the
PCI subsystem.  Remove the potentially harmful call.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/atl1c/atl1c_main.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6/drivers/net/atl1c/atl1c_main.c
===================================================================
--- linux-2.6.orig/drivers/net/atl1c/atl1c_main.c
+++ linux-2.6/drivers/net/atl1c/atl1c_main.c
@@ -2718,7 +2718,6 @@ static int __devinit atl1c_probe(struct
 		goto err_reset;
 	}
 
-	device_init_wakeup(&pdev->dev, 1);
 	/* reset the controller to
 	 * put the device in a known good starting state */
 	err = atl1c_phy_init(&adapter->hw);

