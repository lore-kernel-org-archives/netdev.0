From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3 6/7] net: moxa: generate random address
Date: Mon, 20 Jan 2014 12:13:18 +0100
Message-ID: <1390216399-27028-6-git-send-email-jonas.jensen@gmail.com>
References: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The address register is zero:ed on boot, fill it with a randomly generated
address on probe.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20140120

 drivers/net/ethernet/moxa/moxart_ether.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 6df372f..0f25f4dc 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -740,6 +740,12 @@ static int moxart_mac_probe(struct platform_device *pdev)
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
