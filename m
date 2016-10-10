From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] tlan: avoid unused label with PCI=n
Date: Mon, 10 Oct 2016 14:41:10 +0200
Message-ID: <20161010124120.1522425-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Vecera <ivecera@redhat.com>,
        Antonio Quartulli <a@unstable.cc>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While build testing with randconfig on x86, I ran into this warning
that appears to have been around forever

drivers/net/ethernet/ti/tlan.c: In function ‘tlan_probe1’:
drivers/net/ethernet/ti/tlan.c:614:1: error: label ‘err_out’ defined but not used [-Werror=unused-label]

This can be trivially avoided by just moving the label into the
existing #ifdef.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/tlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index ece0ea0f6b38..6c7ec1ddd475 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -610,8 +610,8 @@ static int tlan_probe1(struct pci_dev *pdev, long ioaddr, int irq, int rev,
 #ifdef CONFIG_PCI
 	if (pdev)
 		pci_release_regions(pdev);
-#endif
 err_out:
+#endif
 	if (pdev)
 		pci_disable_device(pdev);
 	return rc;
-- 
2.9.0
