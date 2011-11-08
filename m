From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: [PATCH] net/ll_temac: FIX : Wait for indirect wait to end
Date: Tue,  8 Nov 2011 10:39:57 +0100
Message-ID: <1320745197-11053-1-git-send-email-ricardo.ribalda@gmail.com>
Cc: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
To: davem@davemloft.net, ian.campbell@citrix.com,
	eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While tracing down a connectivity problem on the temac I connected a
probe to the Cross bar irq, and it was triggered when doing
ifdown->ifup.

This is fixed once waiting for the indirect write to end. Since it is
not on the hot path there is no performance loss.

Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 4d1658e..cf59dac 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -114,6 +114,7 @@ void temac_indirect_out32(struct temac_local *lp, int reg, u32 value)
 		return;
 	temac_iow(lp, XTE_LSW0_OFFSET, value);
 	temac_iow(lp, XTE_CTL0_OFFSET, CNTLREG_WRITE_ENABLE_MASK | reg);
+	temac_indirect_busywait(lp);
 }
 
 /**
-- 
1.7.7.1
