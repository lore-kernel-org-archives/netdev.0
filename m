From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH 4/5] net: MOXA ART: generate random address
Date: Fri, 22 Nov 2013 15:57:21 +0100
Message-ID: <1385132242-3204-4-git-send-email-jonas.jensen@gmail.com>
References: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385132242-3204-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The address register is zero:ed on boot, fill it with a randomly generated
address on probe.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20131122

 drivers/net/ethernet/moxa/moxart_ether.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 08c3905..c02075a 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -700,6 +700,12 @@ static int moxart_mac_probe(struct platform_device *pdev)
 		goto init_fail;
 	}
 
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		eth_hw_addr_random(ndev);
+		netdev_info(ndev, "generated random MAC address %pM\n",
+			    ndev->dev_addr);
+	}
+
 	netdev_dbg(ndev, "%s: IRQ=%d address=%pM\n",
 		   __func__, ndev->irq, ndev->dev_addr);
 
-- 
1.8.2.1
