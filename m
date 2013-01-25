From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] mwifiex: don't return zero on failure paths in mwifiex_pcie_init()
Date: Sat, 26 Jan 2013 00:56:03 +0400
Message-ID: <1359147363-9587-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Bing Zhao <bzhao@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If pci_iomap() fails in mwifiex_pcie_init(), it breaks off initialization,
deallocates all resources, but returns zero.
The patch adds -EIO as return value in this case.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/mwifiex/pcie.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 13fbc4e..9d9349c 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -1739,6 +1739,7 @@ static int mwifiex_pcie_init(struct mwifiex_adapter *adapter)
 	card->pci_mmap = pci_iomap(pdev, 0, 0);
 	if (!card->pci_mmap) {
 		dev_err(adapter->dev, "iomap(0) error\n");
+		ret = -EIO;
 		goto err_iomap0;
 	}
 	ret = pci_request_region(pdev, 2, DRV_NAME);
@@ -1749,6 +1750,7 @@ static int mwifiex_pcie_init(struct mwifiex_adapter *adapter)
 	card->pci_mmap1 = pci_iomap(pdev, 2, 0);
 	if (!card->pci_mmap1) {
 		dev_err(adapter->dev, "iomap(2) error\n");
+		ret = -EIO;
 		goto err_iomap2;
 	}
 
-- 
1.7.9.5
