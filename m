From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH] dca: check against empty dca_domains list before unregister
	provider
Date: Wed, 23 May 2012 17:27:07 +0200
Message-ID: <20120523152707.31683.81714.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jiang.liu@huawei.com, chenkeping@huawei.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When providers get blocked unregister_dca_providers() is called ending up
with dca_providers and dca_domain lists emptied. Dca should be prevented from
trying to unregister any provider if dca_domain list is found empty.

Reported-by: Jiang Liu <jiang.liu@huawei.com>
Tested-by: Gaohuai Han <hangaohuai@huawei.com>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dca/dca-core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index bc6f5fa..819dfda 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -420,6 +420,11 @@ void unregister_dca_provider(struct dca_
 
 	raw_spin_lock_irqsave(&dca_lock, flags);
 
+	if (list_empty(&dca_domains)) {
+		raw_spin_unlock_irqrestore(&dca_lock, flags);
+		return;
+	}
+
 	list_del(&dca->node);
 
 	pci_rc = dca_pci_rc_from_dev(dev);
