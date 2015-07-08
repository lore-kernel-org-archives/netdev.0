From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: systemport: Use eth_hw_addr_random
Date: Wed, 8 Jul 2015 10:49:30 +0530
Message-ID: <20150708051930.GA13317@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use eth_hw_addr_random() instead of calling random_ether_addr().
Here, this change is setting addr_assign_type to NET_ADDR_RANDOM.

The Coccinelle semantic patch that performs this transformation
is as follows:

@@
identifier a,b;
@@

-random_ether_addr(a->b);
+eth_hw_addr_random(a);

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
Note that this patch is compile tested only and I have used file
drivers/net/ethernet/hisilicon/hix5hd2_gmac.c as a reference.
Also, original call didn't make assignment to NET_ADDR_RANDOM. So,
it would be good if someone can test this change.
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 909ad7a..4566cdf 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1793,7 +1793,7 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	macaddr = of_get_mac_address(dn);
 	if (!macaddr || !is_valid_ether_addr(macaddr)) {
 		dev_warn(&pdev->dev, "using random Ethernet MAC\n");
-		random_ether_addr(dev->dev_addr);
+		eth_hw_addr_random(dev);
 	} else {
 		ether_addr_copy(dev->dev_addr, macaddr);
 	}
-- 
1.9.1
