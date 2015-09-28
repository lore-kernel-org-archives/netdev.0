From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] bna: fix error handling
Date: Mon, 28 Sep 2015 10:49:48 +0200
Message-ID: <1443430188-32702-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	netdev@vger.kernel.org (open list:BROCADE BNA 10 GIGABIT ETHERNET
	DRIVER)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several functions can return negative value in case of error,
so their return type should be fixed as well as type of variables
to which this value is assigned.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index b7a0f78..9e59663 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1543,7 +1543,7 @@ bfa_flash_cmd_act_check(void __iomem *pci_bar)
 }
 
 /* Flush FLI data fifo. */
-static u32
+static int
 bfa_flash_fifo_flush(void __iomem *pci_bar)
 {
 	u32 i;
@@ -1573,11 +1573,11 @@ bfa_flash_fifo_flush(void __iomem *pci_bar)
 }
 
 /* Read flash status. */
-static u32
+static int
 bfa_flash_status_read(void __iomem *pci_bar)
 {
 	union bfa_flash_dev_status_reg	dev_status;
-	u32				status;
+	int				status;
 	u32			ret_status;
 	int				i;
 
@@ -1611,11 +1611,11 @@ bfa_flash_status_read(void __iomem *pci_bar)
 }
 
 /* Start flash read operation. */
-static u32
+static int
 bfa_flash_read_start(void __iomem *pci_bar, u32 offset, u32 len,
 		     char *buf)
 {
-	u32 status;
+	int status;
 
 	/* len must be mutiple of 4 and not exceeding fifo size */
 	if (len == 0 || len > BFA_FLASH_FIFO_SIZE || (len & 0x03) != 0)
@@ -1703,7 +1703,8 @@ static enum bfa_status
 bfa_flash_raw_read(void __iomem *pci_bar, u32 offset, char *buf,
 		   u32 len)
 {
-	u32 n, status;
+	u32 n;
+	int status;
 	u32 off, l, s, residue, fifo_sz;
 
 	residue = len;
-- 
1.9.1
