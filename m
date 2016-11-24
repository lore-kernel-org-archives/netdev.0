From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH] adm80211: Removed unused 'io_addr' 'mem_addr' variables
Date: Wed, 23 Nov 2016 22:40:45 -0800
Message-ID: <20161124064045.GA8836@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35337 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbcKXGkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 01:40:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial commit cc0b88cf5ecf ([PATCH] Add adm8211 802.11b wireless driver)
introduced variables mem_addr and io_addr in adm80211_probe() that are
set but not used. Compiling with W=1 gives the following warnings,
fix them.

drivers/net/wireless/admtek/adm8211.c: In function ‘adm8211_probe’:
drivers/net/wireless/admtek/adm8211.c:1769:15: warning: variable ‘io_addr’ set but not used [-Wunused-but-set-variable]
  unsigned int io_addr, io_len;
               ^
drivers/net/wireless/admtek/adm8211.c:1768:16: warning: variable ‘mem_addr’ set but not used [-Wunused-but-set-variable]
  unsigned long mem_addr, mem_len;
                ^

These are harmless warnings and are only being fixed to reduce the
noise with W=1 in the kernel. The calls to pci_resource_start do not
have any side-effects and are safe to remove.

Fixes: cc0b88cf5ecf ("[PATCH] Add adm8211 802.11b wireless driver")
Cc: Michael Wu <flamingice@sourmilk.net>
Cc: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 drivers/net/wireless/admtek/adm8211.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/admtek/adm8211.c b/drivers/net/wireless/admtek/adm8211.c
index 70ecd82..70b4da0 100644
--- a/drivers/net/wireless/admtek/adm8211.c
+++ b/drivers/net/wireless/admtek/adm8211.c
@@ -1765,8 +1765,8 @@ static int adm8211_probe(struct pci_dev *pdev,
 {
	struct ieee80211_hw *dev;
	struct adm8211_priv *priv;
-	unsigned long mem_addr, mem_len;
-	unsigned int io_addr, io_len;
+	unsigned long mem_len;
+	unsigned int io_len;
	int err;
	u32 reg;
	u8 perm_addr[ETH_ALEN];
@@ -1778,9 +1778,7 @@ static int adm8211_probe(struct pci_dev *pdev,
		return err;
	}

-	io_addr = pci_resource_start(pdev, 0);
	io_len = pci_resource_len(pdev, 0);
-	mem_addr = pci_resource_start(pdev, 1);
	mem_len = pci_resource_len(pdev, 1);
	if (io_len < 256 || mem_len < 1024) {
		printk(KERN_ERR "%s (adm8211): Too short PCI resources\n",
