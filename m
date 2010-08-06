From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 08/18] isdn: eicon: call disable_pci_device() if pci_probe() failed
Date: Fri,  6 Aug 2010 23:51:48 +0400
Message-ID: <1281124310-13582-1-git-send-email-segooon@gmail.com>
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Huewe <peterhuewe@gmx.de>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64126 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935261Ab0HFTv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 15:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should call disable_pci_device() if it returns from pci_probe()
with error.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/isdn/hardware/eicon/divasmain.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index ed9c555..61e077e 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -743,6 +743,7 @@ static int __devinit divas_init_one(struct pci_dev *pdev,
 			CardProperties[ent->driver_data].
 			Name, pdev->bus->number,
 			pdev->devfn);
+		pci_disable_device(pdev);
 		return (-EIO);
 	}
 
-- 
1.7.0.4

