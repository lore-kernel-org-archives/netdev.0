From: akpm@linux-foundation.org
Subject: [patch 2/7] natsemi section fix
Date: Fri, 08 Feb 2008 03:11:15 -0800
Message-ID: <200802081120.m18BK7Fh021626@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33534 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964880AbYBHLV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/natsemi.c:245: error: natsemi_pci_info causes a section type conflict

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/natsemi.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/natsemi.c~natsemi-section-fix drivers/net/natsemi.c
--- a/drivers/net/natsemi.c~natsemi-section-fix
+++ a/drivers/net/natsemi.c
@@ -127,7 +127,7 @@ static int full_duplex[MAX_UNITS];
 #define NATSEMI_RX_LIMIT	2046	/* maximum supported by hardware */
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitdata =
+static char version[] __devinitdata =
   KERN_INFO DRV_NAME " dp8381x driver, version "
       DRV_VERSION ", " DRV_RELDATE "\n"
   KERN_INFO "  originally by Donald Becker <becker@scyld.com>\n"
@@ -238,7 +238,7 @@ enum {
 };
 
 /* array of board data directly indexed by pci_tbl[x].driver_data */
-static const struct {
+static struct {
 	const char *name;
 	unsigned long flags;
 	unsigned int eeprom_size;
@@ -247,7 +247,7 @@ static const struct {
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
 
-static const struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
+static struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
 	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }	/* terminate list */
_
