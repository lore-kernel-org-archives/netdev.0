From: hahnjo <linux@hahnjo.de>
Subject: [PATCH] alx: Reset phy speed after resume
Date: Thu, 14 Nov 2013 17:16:13 +0100
Message-ID: <1384445773.29057.5.camel@localhost.tld>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
	johannes@sipsolutions.net, wangyijing@huawei.com,
	maarten.lankhorst@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 27744b24f9291782c1342dbd6cac511e68da907c Mon Sep 17 00:00:00 2001
From: hahnjo <hahnjo@hahnjo.de>
Date: Tue, 12 Nov 2013 18:19:24 +0100
Subject: [PATCH] alx: Reset phy speed after resume

This fixes bug 62491 (https://bugzilla.kernel.org/show_bug.cgi?id=62491).
After resuming some users got the following error flooding the kernel log:
alx 0000:02:00.0: invalid PHY speed/duplex: 0xffff

Signed-off-by: Jonas Hahnfeld <linux@hahnjo.de>
---
 drivers/net/ethernet/atheros/alx/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index fc95b23..6305a5d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1389,6 +1389,9 @@ static int alx_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct alx_priv *alx = pci_get_drvdata(pdev);
+	struct alx_hw *hw = &alx->hw;
+
+	alx_reset_phy(hw);
 
 	if (!netif_running(alx->dev))
 		return 0;
-- 
1.8.4.2
