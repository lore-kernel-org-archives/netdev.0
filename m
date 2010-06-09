From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] r8169: fix mdio_read and update mdio_write according to hw specs
Date: Wed,  9 Jun 2010 08:22:10 +0300
Message-ID: <1276060930-15697-1-git-send-email-timo.teras@iki.fi>
References: <BD599B881C1D407DA7BC93A9244650B0@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayeswang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:36397 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab0FIFWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 01:22:40 -0400
Received: by ewy23 with SMTP id 23so262321ewy.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 22:22:39 -0700 (PDT)
In-Reply-To: <BD599B881C1D407DA7BC93A9244650B0@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realtek confirmed that a 20us delay is needed after mdio_read and
mdio_write operations. Reduce the delay in mdio_write, and add it
to mdio_read too. Also add a comment that the 20us is from hw specs.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayeswang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 03a8318..96b6cfb 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -560,10 +560,10 @@ static void mdio_write(void __iomem *ioaddr, int =
reg_addr, int value)
 		udelay(25);
 	}
 	/*
-	 * Some configurations require a small delay even after the write
-	 * completed indication or the next write might fail.
+	 * According to hardware specs a 20us delay is required after write
+	 * complete indication, but before sending next command.
 	 */
-	udelay(25);
+	udelay(20);
 }
=20
 static int mdio_read(void __iomem *ioaddr, int reg_addr)
@@ -583,6 +583,12 @@ static int mdio_read(void __iomem *ioaddr, int reg=
_addr)
 		}
 		udelay(25);
 	}
+	/*
+	 * According to hardware specs a 20us delay is required after read
+	 * complete indication, but before sending next command.
+	 */
+	udelay(20);
+
 	return value;
 }
=20
--=20
1.7.0.4

