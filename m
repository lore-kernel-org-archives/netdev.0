From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] wan: Use usleep_range()
Date: Sat, 31 May 2014 17:07:51 +0200
Message-ID: <1401548871-12352-1-git-send-email-manuel.schoelling@gmx.de>
References: <E603DC592C92B54A89CEF6B0919A0B1CAFDE223C6D@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: kevin.curtis@farsite.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAFDE223C6D@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of using a jiffies hack we can use the standard api for delays.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/wan/farsync.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index bcfff0d..02f6d1c 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -26,6 +26,7 @@
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <linux/delay.h>
 #include <linux/if.h>
 #include <linux/hdlc.h>
 #include <asm/io.h>
@@ -678,7 +679,6 @@ static inline void
 fst_cpureset(struct fst_card_info *card)
 {
 	unsigned char interrupt_line_register;
-	unsigned long j =3D jiffies + 1;
 	unsigned int regval;
=20
 	if (card->family =3D=3D FST_FAMILY_TXU) {
@@ -696,16 +696,12 @@ fst_cpureset(struct fst_card_info *card)
 		/*
 		 * We are delaying here to allow the 9054 to reset itself
 		 */
-		j =3D jiffies + 1;
-		while (jiffies < j)
-			/* Do nothing */ ;
+		usleep_range(10, 20);
 		outw(0x240f, card->pci_conf + CNTRL_9054 + 2);
 		/*
 		 * We are delaying here to allow the 9054 to reload its eeprom
 		 */
-		j =3D jiffies + 1;
-		while (jiffies < j)
-			/* Do nothing */ ;
+		usleep_range(10, 20);
 		outw(0x040f, card->pci_conf + CNTRL_9054 + 2);
=20
 		if (pci_write_config_byte
--=20
1.7.10.4
