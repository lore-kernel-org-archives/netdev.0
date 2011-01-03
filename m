From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: [PATCH] smsc-ircc2: Fix section mismatch derived from smsc_ircc_pnp_probe()
Date: Mon,  3 Jan 2011 22:15:58 +0100
Message-ID: <1294089358-2968-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
To: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following warning:

drivers/net/irda/smsc-ircc2.o(.data+0x18): Section mismatch in reference from the variable smsc_ircc_pnp_driver to the function .init.text:smsc_ircc_pnp_probe()
The variable smsc_ircc_pnp_driver references
the function __init smsc_ircc_pnp_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

Tested with linux-next (next-20101231)

Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 drivers/net/irda/smsc-ircc2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 8c57bfb..1c1677c 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -376,7 +376,7 @@ MODULE_DEVICE_TABLE(pnp, smsc_ircc_pnp_table);
 static int pnp_driver_registered;
 
 #ifdef CONFIG_PNP
-static int __init smsc_ircc_pnp_probe(struct pnp_dev *dev,
+static int __devinit smsc_ircc_pnp_probe(struct pnp_dev *dev,
 				      const struct pnp_device_id *dev_id)
 {
 	unsigned int firbase, sirbase;
-- 
1.7.4.rc0
