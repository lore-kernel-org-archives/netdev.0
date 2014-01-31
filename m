From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 08/34] cxgb4vf: Remove superfluous call to pci_disable_msix()
Date: Fri, 31 Jan 2014 16:08:27 +0100
Message-ID: <b33d0be122a433109d0fa1ec7604ed021dcae08c.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to call pci_disable_msix() in case
the previous call to pci_enable_msix() failed

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 0899c09..509fed9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2475,7 +2475,6 @@ static int enable_msix(struct adapter *adapter)
 		for (i = 0; i < want; ++i)
 			adapter->msix_info[i].vec = entries[i].vector;
 	} else if (err > 0) {
-		pci_disable_msix(adapter->pdev);
 		dev_info(adapter->pdev_dev, "only %d MSI-X vectors left,"
 			 " not using MSI-X\n", err);
 	}
-- 
1.7.7.6
