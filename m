From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] via-ircc: don't return zero if via_ircc_open() failed
Date: Fri, 16 Aug 2013 23:48:14 +0300
Message-ID: <1376686094-28780-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If via_ircc_open() fails, data structures of the driver left uninitialized,
but probe (via_init_one()) returns zero. That can lead to null pointer dereference
in via_remove_one(), since it does not check drvdata for NULL.

The patch implements proper error code propagation.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/irda/via-ircc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 51f2bc3..2dcc60f 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -210,8 +210,7 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 			pci_write_config_byte(pcidev,0x42,(bTmp | 0xf0));
 			pci_write_config_byte(pcidev,0x5a,0xc0);
 			WriteLPCReg(0x28, 0x70 );
-			if (via_ircc_open(pcidev, &info, 0x3076) == 0)
-				rc=0;
+			rc = via_ircc_open(pcidev, &info, 0x3076);
 		} else
 			rc = -ENODEV; //IR not turn on	 
 	} else { //Not VT1211
@@ -249,8 +248,7 @@ static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id)
 			info.irq=FirIRQ;
 			info.dma=FirDRQ1;
 			info.dma2=FirDRQ0;
-			if (via_ircc_open(pcidev, &info, 0x3096) == 0)
-				rc=0;
+			rc = via_ircc_open(pcidev, &info, 0x3096);
 		} else
 			rc = -ENODEV; //IR not turn on !!!!!
 	}//Not VT1211
-- 
1.8.1.2
