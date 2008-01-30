From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] [SIS190] Constify data marked as __devinitdata
Date: Wed, 30 Jan 2008 11:53:08 +0100
Message-ID: <1201690388-9052-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:57472 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbYA3LMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 06:12:20 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 62045A0160
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 11:53:09 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes build error as gcc complains about a "section type conflict"
due to the const __devinitdata in sis190_get_mac_addr_from_apc().
---
 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..e48e4ad 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static const struct pci_device_id sis190_pci_tbl[] __devinitdata = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
-- 
1.5.3.8


