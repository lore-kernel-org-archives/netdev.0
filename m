From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 1/3] forcedeth: fix buffer overflow
Date: Fri, 24 Aug 2012 20:22:51 -0700
Message-ID: <527de689e5eff49f66a8da7aff05ad72b8b97c04.1345864542.git.decot@googlers.com>
References: <cover.1345864542.git.decot@googlers.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345864542.git.decot@googlers.com>
In-Reply-To: <cover.1345864542.git.decot@googlers.com>
References: <cover.1345864542.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found by manual code inspection.

Tested: compile, reboot, ethtool -d ethX


Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index f45def0..51d19d8 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4435,7 +4435,7 @@ static void nv_get_regs(struct net_device *dev, struct ethtool_regs *regs, void
 
 	regs->version = FORCEDETH_REGS_VER;
 	spin_lock_irq(&np->lock);
-	for (i = 0; i <= np->register_size/sizeof(u32); i++)
+	for (i = 0; i < np->register_size/sizeof(u32); i++)
 		rbuf[i] = readl(base + i*sizeof(u32));
 	spin_unlock_irq(&np->lock);
 }
-- 
1.7.10.2.5.g20d7bc9
