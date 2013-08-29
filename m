From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] net/fec: cleanup types in fec_get_mac()
Date: Thu, 29 Aug 2013 11:25:14 +0300
Message-ID: <20130829082514.GB14334@elgon.mountain>
References: <1377261869.3364.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	devicetree@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Grant Likely <grant.likely@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20221 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887Ab3H2IZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 04:25:33 -0400
Content-Disposition: inline
In-Reply-To: <1377261869.3364.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My static checker complains that on some arches unsigned longs can be 8
characters which is larger than the buffer is only 6 chars.
Additionally, Ben Hutchings points out that the buffer actually holds
big endian data and the buffer we are reading from is CPU endian.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: fix endian annotations and reverse the beXX_to_cpu() calls so that
    they say cpu_to_beXX().

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fdf9307..0b12866 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1100,10 +1100,10 @@ static void fec_get_mac(struct net_device *ndev)
 	 * 4) FEC mac registers set by bootloader
 	 */
 	if (!is_valid_ether_addr(iap)) {
-		*((unsigned long *) &tmpaddr[0]) =
-			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
-		*((unsigned short *) &tmpaddr[4]) =
-			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
+		*((__be32 *) &tmpaddr[0]) =
+			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
+		*((__be16 *) &tmpaddr[4]) =
+			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
 		iap = &tmpaddr[0];
 	}
 
