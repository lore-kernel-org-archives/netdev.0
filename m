From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 18/27] drivers/net/tulip: fix sparse warnings: make do-while a
	compound statement
Date: Mon, 22 Dec 2008 20:17:37 +0100
Message-ID: <20081222191737.11807.16256.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891AbYLVTRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:17:42 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/tulip/de2104x.c:1695:4: warning: do-while statement is not a compound statement
  drivers/net/tulip/tulip_core.c:1433:5: warning: do-while statement is not a compound statement

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/tulip/de2104x.c    |    4 ++--
 drivers/net/tulip/tulip_core.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 3aa60fa..5166be9 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1691,9 +1691,9 @@ static void __devinit de21040_get_mac_address (struct de_private *de)
 
 	for (i = 0; i < 6; i++) {
 		int value, boguscnt = 100000;
-		do
+		do {
 			value = dr32(ROMCmd);
-		while (value < 0 && --boguscnt > 0);
+		} while (value < 0 && --boguscnt > 0);
 		de->dev->dev_addr[i] = value;
 		udelay(1);
 		if (boguscnt <= 0)
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 1c5ef23..ff84bab 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1429,9 +1429,9 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		for (i = 0; i < 3; i++) {
 			int value, boguscnt = 100000;
 			iowrite32(0x600 | i, ioaddr + 0x98);
-			do
+			do {
 				value = ioread32(ioaddr + CSR9);
-			while (value < 0  && --boguscnt > 0);
+			} while (value < 0  && --boguscnt > 0);
 			put_unaligned_le16(value, ((__le16 *)dev->dev_addr) + i);
 			sum += value & 0xffff;
 		}

