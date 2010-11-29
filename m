From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 1/5] firewire: ohci: restore GUID on resume.
Date: Mon, 29 Nov 2010 04:09:49 +0200
Message-ID: <1290996593-32416-2-git-send-email-maximlevitsky@gmail.com>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48670 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab0K2CKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:10:19 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so3474612bwz.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 18:10:18 -0800 (PST)
In-Reply-To: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some lousy BIOSes, e.g. my Aspire 5720 BIOS forget to restore
the GUID register on resume from ram.

Fix that by setting it to the last value that
was read from it.

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/ohci.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/ohci.c b/drivers/firewire/ohci.c
index 6dd56cd..0fbadb7 100644
--- a/drivers/firewire/ohci.c
+++ b/drivers/firewire/ohci.c
@@ -3240,6 +3240,13 @@ static int pci_resume(struct pci_dev *dev)
 		return err;
 	}
 
+	/* Some systems don't setup GUID register on resume from ram  */
+	if (!reg_read(ohci, OHCI1394_GUIDLo) &&
+					!reg_read(ohci, OHCI1394_GUIDHi)) {
+		reg_write(ohci, OHCI1394_GUIDLo, (u32)ohci->card.guid);
+		reg_write(ohci, OHCI1394_GUIDHi, (u32)(ohci->card.guid >> 32));
+	}
+
 	return ohci_enable(&ohci->card, NULL, 0);
 }
 #endif
-- 
1.7.1

