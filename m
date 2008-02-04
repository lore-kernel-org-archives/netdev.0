From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [PATCH] 2.6.24-mm1 section type conflict cleanup
Date: Mon, 4 Feb 2008 21:52:23 +0530
Message-ID: <20080204162223.GA6888@linux.vnet.ibm.com>
References: <20080203171634.58ab668b.akpm@linux-foundation.org>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sam@ravnborg.org, apw@shadowen.org, balbir@linux.vnet.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:43753 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751633AbYBDQWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 11:22:36 -0500
Content-Disposition: inline
In-Reply-To: <20080203171634.58ab668b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

The 2.6.24-mm1 kernel build fails at many places with section type
conflict build error.

drivers/net/typhoon.c:181: error: typhoon_card_info causes a section type conflict
make[2]: *** [drivers/net/typhoon.o] Error 1

drivers/net/natsemi.c:245: error: natsemi_pci_info causes a section type conflict
make[2]: *** [drivers/net/natsemi.o] Error 1

drivers/net/bnx2.c:95: error: board_info causes a section type conflict
make[2]: *** [drivers/net/bnx2.o] Error 1

drivers/net/bnx2x.c:112: error: board_info causes a section type conflict
make[2]: *** [drivers/net/bnx2x.o] Error 1

drivers/net/bnx2x.c:112: error: board_info causes a section type conflict
make[2]: *** [drivers/net/bnx2x.o] Error 1

drivers/net/via-velocity.c:453: error: velocity_id_table causes a section type conflict
make[2]: *** [drivers/net/via-velocity.o] Error 1

drivers/net/starfire.c:350: error: netdrv_tbl causes a section type conflict
make[2]: *** [drivers/net/starfire.o] Error 1


I have tested the patch for build test only

Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
--
--- linux-2.6.24/drivers/net/typhoon.c	2008-01-25 04:28:37.000000000 +0530
+++ linux-2.6.24/drivers/net/~typhoon.c	2008-02-04 16:21:55.000000000 +0530
@@ -178,7 +178,7 @@ enum typhoon_cards {
 };
 
 /* directly indexed by enum typhoon_cards, above */
-static const struct typhoon_card_info typhoon_card_info[] __devinitdata = {
+static const struct typhoon_card_info typhoon_card_info[] __devinitconst = {
 	{ "3Com Typhoon (3C990-TX)",
 		TYPHOON_CRYPTO_NONE},
 	{ "3Com Typhoon (3CR990-TX-95)",
--- linux-2.6.24/drivers/net/natsemi.c	2008-02-04 14:57:00.000000000 +0530
+++ linux-2.6.24/drivers/net/~natsemi.c	2008-02-04 16:36:22.000000000 +0530
@@ -242,7 +242,7 @@ static const struct {
 	const char *name;
 	unsigned long flags;
 	unsigned int eeprom_size;
-} natsemi_pci_info[] __devinitdata = {
+} natsemi_pci_info[] __devinitconst = {
 	{ "Aculab E1/T1 PMXc cPCI carrier card", NATSEMI_FLAG_IGNORE_PHY, 128 },
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
--- linux-2.6.24/drivers/net/bnx2.c	2008-02-04 14:56:59.000000000 +0530
+++ linux-2.6.24/drivers/net/~bnx2.c	2008-02-04 16:44:02.000000000 +0530
@@ -92,7 +92,7 @@ typedef enum {
 /* indexed by board_t, above */
 static const struct {
 	char *name;
-} board_info[] __devinitdata = {
+} board_info[] __devinitconst = {
 	{ "Broadcom NetXtreme II BCM5706 1000Base-T" },
 	{ "HP NC370T Multifunction Gigabit Server Adapter" },
 	{ "HP NC370i Multifunction Gigabit Server Adapter" },
--- linux-2.6.24/drivers/net/bnx2.c	2008-02-04 16:44:47.000000000 +0530
+++ linux-2.6.24/drivers/net/~bnx2.c	2008-02-04 16:47:08.000000000 +0530
@@ -104,7 +104,7 @@ static const struct {
 	{ "Broadcom NetXtreme II BCM5709 1000Base-SX" },
 	};
 
-static struct pci_device_id bnx2_pci_tbl[] = {
+static struct pci_device_id bnx2_pci_tbl[] __devinitconst = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
 	  PCI_VENDOR_ID_HP, 0x3101, 0, 0, NC370T },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
--- linux-2.6.24/drivers/net/bnx2x.c	2008-02-04 14:57:00.000000000 +0530
+++ linux-2.6.24/drivers/net/~bnx2x.c	2008-02-04 18:01:14.000000000 +0530
@@ -109,7 +109,7 @@ enum bnx2x_board_type {
 /* indexed by board_t, above */
 static const struct {
 	char *name;
-} board_info[] __devinitdata = {
+} board_info[] __devinitconst = {
 	{ "Broadcom NetXtreme II BCM57710 XGb" }
 };
 
--- linux-2.6.24/drivers/net/starfire.c	2008-01-25 04:28:37.000000000 +0530
+++ linux-2.6.24/drivers/net/~starfire.c	2008-02-04 18:08:08.000000000 +0530
@@ -347,7 +347,7 @@ MODULE_DEVICE_TABLE(pci, starfire_pci_tb
 static const struct chip_info {
 	const char *name;
 	int drv_flags;
-} netdrv_tbl[] __devinitdata = {
+} netdrv_tbl[] __devinitconst = {
 	{ "Adaptec Starfire 6915", CanHaveMII },
 };
 
--- linux-2.6.24/drivers/net/via-velocity.c	2008-02-04 14:57:00.000000000 +0530
+++ linux-2.6.24/drivers/net/~via-velocity.c	2008-02-04 18:04:21.000000000 +0530
@@ -450,7 +450,7 @@ static const struct velocity_info_tbl ch
  *	device driver. Used for hotplug autoloading.
  */
 
-static const struct pci_device_id velocity_id_table[] __devinitdata = {
+static const struct pci_device_id velocity_id_table[] __devinitconst = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
 };
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
