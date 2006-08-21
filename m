From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 11/14] ipw2200: Add pci .shutdown handler
Date: Mon, 21 Aug 2006 11:38:39 +0800
Message-ID: <20060821033839.GA5416@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21093 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932588AbWHUDke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:34 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we don't disable the card in the pci .shutdown method, there might be
pending interrupts still in the interrupt line after a reboot on some
platform. This patch fixes the problem by disable the hardware in the pci
.shutdown method.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

4c30e540c4cf2dd75fd82ac7d4f3a7ce80b9b32f
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index e18fbca..1525830 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11735,6 +11735,16 @@ static int ipw_pci_resume(struct pci_dev
 }
 #endif
 
+static void ipw_pci_shutdown(struct pci_dev *pdev)
+{
+	struct ipw_priv *priv = pci_get_drvdata(pdev);
+
+	/* Take down the device; powers it off, etc. */
+	ipw_down(priv);
+
+	pci_disable_device(pdev);
+}
+
 /* driver initialization stuff */
 static struct pci_driver ipw_driver = {
 	.name = DRV_NAME,
@@ -11745,6 +11755,7 @@ static struct pci_driver ipw_driver = {
 	.suspend = ipw_pci_suspend,
 	.resume = ipw_pci_resume,
 #endif
+	.shutdown = ipw_pci_shutdown,
 };
 
 static int __init ipw_init(void)
-- 
1.2.6
