From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] pcnet32: Read buffer overflow
Date: Fri, 07 Aug 2009 15:24:27 +0200
Message-ID: <4A7C2B0B.9030508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Don Fry <pcnet32@verizon.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:51183 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbZHGNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 09:20:52 -0400
Received: by ewy10 with SMTP id 10so1523815ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 06:20:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An `options[cards_found]' that equals `sizeof(options_mapping)' is already beyond
the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 2836815..7f834a3 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1835,7 +1835,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	lp->chip_version = chip_version;
 	lp->msg_enable = pcnet32_debug;
 	if ((cards_found >= MAX_UNITS)
-	    || (options[cards_found] > sizeof(options_mapping)))
+	    || (options[cards_found] >= sizeof(options_mapping)))
 		lp->options = PCNET32_PORT_ASEL;
 	else
 		lp->options = options_mapping[options[cards_found]];
