From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: [PATCH] ksz884x: Fix section mismatch derived from pci_device_driver variable
Date: Mon,  3 Jan 2011 03:01:44 +0100
Message-ID: <1294020104-17124-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARNING: drivers/net/ksz884x.o(.data+0x18): Section mismatch in reference from the variable pci_device_driver to the function .init.text:pcidev_init()
The variable pci_device_driver references
the function __init pcidev_init()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

This patch fixes the warning.

Tested with linux-next (next-20101231)

Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 drivers/net/ksz884x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 49ea870..515b0d7 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -7277,7 +7277,7 @@ static struct pci_device_id pcidev_table[] = {
 
 MODULE_DEVICE_TABLE(pci, pcidev_table);
 
-static struct pci_driver pci_device_driver = {
+static struct pci_driver pci_device_driver __refdata = {
 #ifdef CONFIG_PM
 	.suspend	= pcidev_suspend,
 	.resume		= pcidev_resume,
-- 
1.7.4.rc0
