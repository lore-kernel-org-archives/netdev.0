From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: added pci_device_id table
Date: Tue, 09 Jun 2009 15:53:47 +0300
Message-ID: <4A2E5B5B.7060701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:54461 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754730AbZFIMEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 08:04:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required to ensure that mlx4_en module loads on boot when
there are ConnectX devices installed.
The driver is compound from two modules: mlx4_core, the low level module
and mlx4_en. Currently mlx4_core is the only module that is loaded on boot,
this is not enough to enable the ConnectX Ethernet interfaces.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 9ed4a15..862696f 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -266,6 +266,22 @@ static struct mlx4_interface mlx4_en_interface = {
 	.event	= mlx4_en_event,
 };
 
+static struct pci_device_id mlx4_en_pci_table[] = {
+	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
+	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
+	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
+	{ PCI_VDEVICE(MELLANOX, 0x6732) }, /* MT25408 "Hermon" DDR PCIe gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x673c) }, /* MT25408 "Hermon" QDR PCIe gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x6368) }, /* MT25408 "Hermon"EN 10GigE */
+	{ PCI_VDEVICE(MELLANOX, 0x6750) }, /* MT25408 "Hermon"EN 10GigE + Gen2 */
+	{ PCI_VDEVICE(MELLANOX, 0x6372) }, /* MT25408 "YATIR" EN 10GigE */
+	{ PCI_VDEVICE(MELLANOX, 0x675a) }, /* MT25408 "YATIR" EN 10GigE + Gen2 */
+	{ 0, }
+};
+
+MODULE_DEVICE_TABLE(pci, mlx4_en_pci_table);
+
+
 static int __init mlx4_en_init(void)
 {
 	return mlx4_register_interface(&mlx4_en_interface);
-- 
1.6.0

