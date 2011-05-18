From: David Decotigny <decot@google.com>
Subject: [PATCH] forcedeth: Add messages to indicate using MSI or MSI-X
Date: Wed, 18 May 2011 14:10:48 -0700
Message-ID: <1305753049-15025-2-git-send-email-decot@google.com>
References: <1305753049-15025-1-git-send-email-decot@google.com>
Cc: kernel-net-upstream@google.com, Mike Ditto <mditto@google.com>,
	David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305753049-15025-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Ditto <mditto@google.com>

This adds a few debug messages to indicate whether PCIe interrupts are
signaled with MSI or MSI-X.


Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/forcedeth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index c9bdee6..e5c5849 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3745,6 +3745,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				writel(0, base + NvRegMSIXMap0);
 				writel(0, base + NvRegMSIXMap1);
 			}
+			netdev_info(dev, "forcedeth: MSI-X enabled\n");
 		}
 	}
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
@@ -3766,6 +3767,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			writel(0, base + NvRegMSIMap1);
 			/* enable msi vector 0 */
 			writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
+			netdev_info(dev, "forcedeth: MSI enabled\n");
 		}
 	}
 	if (ret != 0) {
-- 
1.7.3.1
