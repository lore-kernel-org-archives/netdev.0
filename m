From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] net/nuc900: enable Mac driver clock
Date: Wed, 14 Jul 2010 17:48:45 +0800
Message-ID: <4C3D87FD.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixed a bug that Mac driver does not work,because I missed the clk enable.

I have ever tested the driver when I submitted previous Mac driver patch,
and it worked good, since my bootloader has enabled the clock in advance.

But when I try to use other bootloader where clock engine was disabled,the
Mac driver does not work, so I send this patch to fix this issue.

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

---
 drivers/net/arm/w90p910_ether.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 2e85246..4545d5a 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -822,6 +822,9 @@ static int w90p910_ether_open(struct net_device *dev)
 	w90p910_set_global_maccmd(dev);
 	w90p910_enable_rx(dev, 1);

+	clk_enable(ether->rmiiclk);
+	clk_enable(ether->clk);
+
 	ether->rx_packets = 0x0;
 	ether->rx_bytes = 0x0;

-- 
1.6.3.3
