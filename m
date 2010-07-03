From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 12/19] drivers/net: use for_each_pci_dev()
Date: Sat,  3 Jul 2010 20:04:19 +0400
Message-ID: <1278173061-11813-1-git-send-email-segooon@gmail.com>
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39669 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755676Ab0GCQKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 12:10:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use for_each_pci_dev() to simplify the code.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 22371f1..5c2bd50 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1094,7 +1094,7 @@ static int s2io_verify_pci_mode(struct s2io_nic *nic)
 static int s2io_on_nec_bridge(struct pci_dev *s2io_pdev)
 {
 	struct pci_dev *tdev = NULL;
-	while ((tdev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, tdev)) != NULL) {
+	for_each_pci_dev(tdev) {
 		if (tdev->vendor == NEC_VENID && tdev->device == NEC_DEVID) {
 			if (tdev->bus == s2io_pdev->bus->parent) {
 				pci_dev_put(tdev);
-- 
1.7.0.4

