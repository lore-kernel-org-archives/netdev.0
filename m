From: Chris Brandt <chris.brandt@renesas.com>
Subject: [PATCH v2] net: ethernet: renesas: sh_eth: add POST registers for rz
Date: Wed,  7 Sep 2016 14:57:09 -0400
Message-ID: <20160907185709.24150-1-chris.brandt@renesas.com>
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Daniel Palmer <daniel@0x0f.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Chris Brandt <chris.brandt@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Due to a mistake in the hardware manual, the FWSLC and POST1-4 registers
were not documented and left out of the driver for RZ/A making the CAM
feature non-operational.
Additionally, when the offset values for POST1-4 are left blank, the driver
attempts to set them using an offset of 0xFFFF which can cause a memory
corruption or panic.

This patch fixes the panic and properly enables CAM.

Reported-by: Daniel Palmer <daniel@0x0f.com>
Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
---
v2:
* POST registers really do exist, so just add them
---
 drivers/net/ethernet/renesas/sh_eth.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 1f8240a..440ae27 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -201,9 +201,14 @@ static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
 
 	[ARSTR]		= 0x0000,
 	[TSU_CTRST]	= 0x0004,
+	[TSU_FWSLC]	= 0x0038,
 	[TSU_VTAG0]	= 0x0058,
 	[TSU_ADSBSY]	= 0x0060,
 	[TSU_TEN]	= 0x0064,
+	[TSU_POST1]	= 0x0070,
+	[TSU_POST2]	= 0x0074,
+	[TSU_POST3]	= 0x0078,
+	[TSU_POST4]	= 0x007c,
 	[TSU_ADRH0]	= 0x0100,
 
 	[TXNLCR0]	= 0x0080,
@@ -2781,6 +2786,8 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
 {
 	if (sh_eth_is_rz_fast_ether(mdp)) {
 		sh_eth_tsu_write(mdp, 0, TSU_TEN); /* Disable all CAM entry */
+		sh_eth_tsu_write(mdp, TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL,
+				 TSU_FWSLC);	/* Enable POST registers */
 		return;
 	}
 
-- 
2.9.2
