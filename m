From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/hplance: hplance_init() should be __devinit
Date: Mon, 13 Jun 2011 20:17:36 +0200
Message-ID: <1307989056-21814-1-git-send-email-geert@linux-m68k.org>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: netdev@vger.kernel.org
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARNING: vmlinux.o(.devinit.text+0x253e): Section mismatch in reference from the function hplance_init_one() to the function .init.text:hplance_init()

The forward declaration had the correct attribute, but the actual function
definition hadn't.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/hplance.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index b6060f7..a900d5b 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -135,7 +135,7 @@ static void __devexit hplance_remove_one(struct dio_dev *d)
 }
 
 /* Initialise a single lance board at the given DIO device */
-static void __init hplance_init(struct net_device *dev, struct dio_dev *d)
+static void __devinit hplance_init(struct net_device *dev, struct dio_dev *d)
 {
         unsigned long va = (d->resource.start + DIO_VIRADDRBASE);
         struct hplance_private *lp;
-- 
1.7.0.4
