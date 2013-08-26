From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [PATCH] net: xilinx: fix memleak
Date: Mon, 26 Aug 2013 11:30:55 +0800
Message-ID: <521ACBEF.7020301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>, <anirudh@xilinx.com>,
	<John.Linn@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 decrease device_node refcount np1 in err case.

Signed-off-by: Libo Chen <libo.chen@huawei.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
index e90e1f4..64b4639 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
@@ -175,6 +175,7 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
 		printk(KERN_WARNING "Setting MDIO clock divisor to "
 		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
 		clk_div = DEFAULT_CLOCK_DIVISOR;
+		of_node_put(np1);
 		goto issue;
 	}

-- 
1.7.1
