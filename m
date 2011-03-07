From: Michel Lespinasse <walken@google.com>
Subject: [PATCH] drivers/net: fix build warnings with CONFIG_PM_SLEEP
 disabled
Date: Sun, 6 Mar 2011 18:14:50 -0800
Message-ID: <20110307021450.GC31188@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a couple of build warnings when CONFIG_PM is enabled but
CONFIG_PM_SLEEP is disabled. Applies on top of v2.6.38-rc7 - I know it's
late, but it would be great if v2.6.38 could compile without warnings!

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 drivers/net/forcedeth.c |    8 ++++++--
 drivers/net/sky2.c      |    2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 9c0b1ba..7b92897 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5744,7 +5744,7 @@ static void __devexit nv_remove(struct pci_dev *pci_dev)
 	pci_set_drvdata(pci_dev, NULL);
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int nv_suspend(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
@@ -5795,6 +5795,11 @@ static int nv_resume(struct device *device)
 static SIMPLE_DEV_PM_OPS(nv_pm_ops, nv_suspend, nv_resume);
 #define NV_PM_OPS (&nv_pm_ops)
 
+#else
+#define NV_PM_OPS NULL
+#endif /* CONFIG_PM_SLEEP */
+
+#ifdef CONFIG_PM
 static void nv_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -5822,7 +5827,6 @@ static void nv_shutdown(struct pci_dev *pdev)
 	}
 }
 #else
-#define NV_PM_OPS NULL
 #define nv_shutdown NULL
 #endif /* CONFIG_PM */
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7d85a38..2a91868 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4983,7 +4983,7 @@ static int sky2_suspend(struct device *dev)
 	return 0;
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int sky2_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
