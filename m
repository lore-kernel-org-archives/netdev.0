From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [PATCH 13/13] mISDN: hfcmulti display real PCI ids for not supported
	cards
Date: Fri, 24 Jul 2009 18:41:23 +0200
Message-ID: <f70e75e11069edfbe55be06960854c46860da0a3.1248546897.git.keil@b1-systems.de>
References: <cover.1248546896.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1248546896.git.keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

In the PCI probe function struct pci_device_id points to the matched
entry of the ID table, but for devices which are matched with
PCI_ANY_ID sub IDs we want display the IDs of the device itself.

Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index fd77bb1..faed794 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5370,9 +5370,10 @@ hfcmulti_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    ent->device == PCI_DEVICE_ID_CCD_HFC8S ||
 	    ent->device == PCI_DEVICE_ID_CCD_HFCE1)) {
 		printk(KERN_ERR
-		    "Unknown HFC multiport controller (vendor:%x device:%x "
-		    "subvendor:%x subdevice:%x)\n", ent->vendor, ent->device,
-		    ent->subvendor, ent->subdevice);
+		    "Unknown HFC multiport controller (vendor:%04x device:%04x "
+		    "subvendor:%04x subdevice:%04x)\n", pdev->vendor,
+		    pdev->device, pdev->subsystem_vendor,
+		    pdev->subsystem_device);
 		printk(KERN_ERR
 		    "Please contact the driver maintainer for support.\n");
 		return -ENODEV;
-- 
1.6.0.2
