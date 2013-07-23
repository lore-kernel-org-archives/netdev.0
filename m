From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v4 net-next repost 1/2] sh_eth: add support for RMIIMODE register
Date: Tue, 23 Jul 2013 10:18:04 +0900
Message-ID: <1374542285-19602-2-git-send-email-horms+renesas@verge.net.au>
References: <1374542285-19602-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374542285-19602-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This register is prsent on the r8a7790 SoC.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

--

v4
* Update changelog.

v3
* The subsequent patch to add r8a7790 support has been reworked.
  To reflect this do not add set the rmmimode bit of any
  currently available struct sh_eth_cpu_data. A new one
  will be added for r8a7790 and the bit will be set when
  it is added.

v2
* Split from patch to add r8a7790 support to driver (ifdef nastiness)
* As suggested by Sergei Shtylyov
  - Add a field to struct sh_eth_cpu_data to indicate if the
    rmiimode register is present. This replaces an extremely ugly ifdef.
---
 drivers/net/ethernet/renesas/sh_eth.c | 4 ++++
 drivers/net/ethernet/renesas/sh_eth.h | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a753928..87af49f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -189,6 +189,7 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[RMCR]		= 0x0258,
 	[TFUCR]		= 0x0264,
 	[RFOCR]		= 0x0268,
+	[RMIIMODE]      = 0x026c,
 	[FCFTR]		= 0x0270,
 	[TRIMD]		= 0x027c,
 };
@@ -1124,6 +1125,9 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	if (ret)
 		goto out;
 
+	if (mdp->cd->rmiimode)
+		sh_eth_write(ndev, 0x1, RMIIMODE);
+
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
 	if (mdp->cd->rpadir)
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 99995bf..da93f5c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -60,6 +60,7 @@ enum {
 	EDOCR,
 	TFUCR,
 	RFOCR,
+	RMIIMODE,
 	FCFTR,
 	RPADIR,
 	TRIMD,
@@ -482,6 +483,7 @@ struct sh_eth_cpu_data {
 	unsigned hw_crc:1;	/* E-DMAC have CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
 	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
+	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
 };
 
 struct sh_eth_private {
-- 
1.8.2.1

