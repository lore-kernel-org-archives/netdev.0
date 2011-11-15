From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v3 2/9] forcedeth: Add messages to indicate using MSI or MSI-X
Date: Mon, 14 Nov 2011 16:11:12 -0800
Message-ID: <97a5a50baaca7b272dfb7a1a06e88df4888f12b9.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	Mike Ditto <mditto@google.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Ditto <mditto@google.com>

This adds a few debug messages to indicate whether PCIe interrupts are
signaled with MSI or MSI-X.



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 374625b..fe17e42 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3810,6 +3810,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				writel(0, base + NvRegMSIXMap0);
 				writel(0, base + NvRegMSIXMap1);
 			}
+			netdev_info(dev, "MSI-X enabled\n");
 		}
 	}
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
@@ -3831,6 +3832,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			writel(0, base + NvRegMSIMap1);
 			/* enable msi vector 0 */
 			writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
+			netdev_info(dev, "MSI enabled\n");
 		}
 	}
 	if (ret != 0) {
-- 
1.7.3.1
