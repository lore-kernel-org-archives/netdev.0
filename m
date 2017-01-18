From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] cxgb4: hide unused warnings
Date: Wed, 18 Jan 2017 15:52:51 +0100
Message-ID: <20170118145306.1004008-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Varun Prakash <varun@chelsio.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The two new variables are only used inside of an #ifdef and cause
harmless warnings when that is disabled:

drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function 'init_one':
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:9: error: unused variable 'port_vec' [-Werror=unused-variable]
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:4646:6: error: unused variable 'v' [-Werror=unused-variable]

This adds another #ifdef around the declarations.

Fixes: 96fe11f27b70 ("cxgb4: Implement ndo_get_phys_port_id for mgmt dev")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4da6f900ff24..49e000ebd2b9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4643,7 +4643,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u32 whoami, pl_rev;
 	enum chip_type chip;
 	static int adap_idx = 1;
+#ifdef CONFIG_PCI_IOV
 	u32 v, port_vec;
+#endif
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
-- 
2.9.0
