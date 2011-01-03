From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: [PATCH] smsc-ircc2: Fix section mismatch derived from smsc_ircc_pnp_driver variable
Date: Mon,  3 Jan 2011 03:28:44 +0100
Message-ID: <1294021724-30337-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
To: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38313 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab1ACC3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 21:29:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From my build.log:

drivers/net/irda/smsc-ircc2.o(.data+0x18): Section mismatch in reference from the variable smsc_ircc_pnp_driver to the function .init.text:smsc_ircc_pnp_probe()
The variable smsc_ircc_pnp_driver references
the function __init smsc_ircc_pnp_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

This patch fixes the warning.

Tested with linux-next (next-20101231)

Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 drivers/net/irda/smsc-ircc2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 8c57bfb..0ebd4a8 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -397,7 +397,7 @@ static int __init smsc_ircc_pnp_probe(struct pnp_dev *dev,
 	return 0;
 }
 
-static struct pnp_driver smsc_ircc_pnp_driver = {
+static struct pnp_driver smsc_ircc_pnp_driver __refdata = {
 	.name		= "smsc-ircc2",
 	.id_table	= smsc_ircc_pnp_table,
 	.probe		= smsc_ircc_pnp_probe,
-- 
1.7.4.rc0

