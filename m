From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 1/5] firewire: ohci: restore GUID register on resume.
Date: Sun, 28 Nov 2010 03:15:32 +0200
Message-ID: <1290906936-14472-2-git-send-email-maximlevitsky@gmail.com>
References: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55574 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab0K1BPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:15:47 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so2883308bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 17:15:46 -0800 (PST)
In-Reply-To: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some lousy BIOSes, eg my Aspire 5720 BIOS forgets to restore
device GUID on resume from ram.

Fix that by programming GUID register on resume from ram
Since that register is one time programable according to spec,
that has no effect on systems that have sane BIOS (Are there any?)

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/ohci.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/firewire/ohci.c b/drivers/firewire/ohci.c
index 6dd56cd..cadd6af 100644
--- a/drivers/firewire/ohci.c
+++ b/drivers/firewire/ohci.c
@@ -3240,6 +3240,10 @@ static int pci_resume(struct pci_dev *dev)
 		return err;
 	}
 
+	/* Some bioses forget to reinitialize the GUID. Do that ourselves */
+	reg_write(ohci, OHCI1394_GUIDLo, ohci->card.guid & 0xFFFFFFFF);
+	reg_write(ohci, OHCI1394_GUIDHi, (ohci->card.guid >> 32) & 0xFFFFFFFF);
+
 	return ohci_enable(&ohci->card, NULL, 0);
 }
 #endif
-- 
1.7.1

