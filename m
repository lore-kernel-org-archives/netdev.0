From: Daniel Halperin <dhalperi@cs.washington.edu>
Subject: [PATCH] skge: fix warning when CONFIG_PM is defined but not CONFIG_PM_SLEEP
Date: Tue, 3 Jan 2012 09:34:48 -0800
Message-ID: <A0790551-53D4-4D01-AB38-615607BCF9CC@cs.washington.edu>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39688 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab2ACReu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:34:50 -0500
Received: by vbbfc26 with SMTP id fc26so12694069vbb.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 09:34:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/ethernet/marvell/skge.c:4046: warning: =91skge_suspend=92 d=
efined but not used
drivers/net/ethernet/marvell/skge.c:4071: warning: =91skge_resume=92 de=
fined but not used

Signed-off-by: Daniel Halperin <dhalperi@cs.washington.edu>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/ethernet/marvell/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet=
/marvell/skge.c
index dea0cb4..e6a007a 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4042,7 +4042,7 @@ static void __devexit skge_remove(struct pci_dev =
*pdev)
 	pci_set_drvdata(pdev, NULL);
 }
=20
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int skge_suspend(struct device *dev)
 {
 	struct pci_dev *pdev =3D to_pci_dev(dev);
@@ -4104,7 +4104,7 @@ static SIMPLE_DEV_PM_OPS(skge_pm_ops, skge_suspen=
d, skge_resume);
 #else
=20
 #define SKGE_PM_OPS NULL
-#endif
+#endif /* CONFIG_PM_SLEEP */
=20
 static void skge_shutdown(struct pci_dev *pdev)
 {
--=20
1.7.0.4
