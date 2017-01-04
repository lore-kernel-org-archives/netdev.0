From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: enable RX descriptor word 0 shift on SH7734
Date: Wed, 04 Jan 2017 23:10:23 +0300
Message-ID: <1893574.OD9Leu8Ck8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RX descriptor word 0 on SH7734 has the RFS[9:0] field in bits 16-25
(bits  0-15 usually used for that are occupied by the packet checksum).
Thus  we need to set the 'shift_rd0'  field in the SH7734 SoC data...

Fixes: f0e81fecd4f8 ("net: sh_eth: Add support SH7734")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    1 +
 1 file changed, 1 insertion(+)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -819,6 +819,7 @@ static struct sh_eth_cpu_data sh7734_dat
 	.tsu		= 1,
 	.hw_crc		= 1,
 	.select_mii	= 1,
+	.shift_rd0	= 1,
 };
 
 /* SH7763 */
