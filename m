From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] ethernet: moxa: fix incorrect placement of __initdata tag
Date: Mon, 30 Sep 2013 15:18:27 +0200
Message-ID: <172588984.DhoE4BmVdc@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Cc: Jonas Jensen <jonas.jensen@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__initdata tag should be placed between the variable name and equal
sign for the variable to be placed in the intended .init.data section.

In this particular case __initdata is incorrect as moxart_mac_driver
can be used after the driver gets initialized.

Also while at it static-ize moxart_mac_driver.

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 83c2091..bd1a2d2 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -543,7 +543,7 @@ static const struct of_device_id moxart_mac_match[] = {
 	{ }
 };
 
-struct __initdata platform_driver moxart_mac_driver = {
+static struct platform_driver moxart_mac_driver = {
 	.probe	= moxart_mac_probe,
 	.remove	= moxart_remove,
 	.driver	= {
-- 
1.8.2.3
