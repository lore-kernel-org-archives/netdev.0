From: "Mario Molitor" <Mario_Molitor@web.de>
Subject: [PATCH 1/2(net.git)] stmmac: fix ptp header for GMAC3 hw timestamp
Date: Wed, 7 Jun 2017 10:42:21 +0200
Message-ID: <trinity-fff77f78-0a67-4c52-8a3e-4fb46c9e1a70-1496824941168@3capp-webde-bs41>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From e87e1a88a3bf054c45156edf8a63d72169064baa Mon Sep 17 00:00:00 2001
From: Mario Molitor <mario_molitor@web.de>
Date: Tue, 6 Jun 2017 21:31:02 +0200
Subject: [PATCH 1/2] stmmac: fix ptp header for GMAC3 hw timestamp

According the CYCLON V documention only the bit 16 of snaptypesel should
set.
(more information see Table 17-20 (cv_5v4.pdf) :
 Timestamp Snapshot Dependency on Register Bits)

fixed: commit d2042052a0aa ("stmmac: update the PTP header file")
Signed-off-by: Mario Molitor <mario_molitor@web.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 15 ++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |  3 ++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a74c481..14d0bf3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -546,7 +546,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			/* PTP v1, UDP, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -578,7 +581,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
@@ -612,7 +618,10 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
-			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
+			if (priv->plat->has_gmac4)
+				snap_type_sel = PTP_GMAC4_TCR_SNAPTYPSEL_1;
+			else
+				snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
 
 			ptp_over_ipv4_udp = PTP_TCR_TSIPV4ENA;
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 48fb72f..f4b31d6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -59,7 +59,8 @@
 /* Enable Snapshot for Messages Relevant to Master */
 #define	PTP_TCR_TSMSTRENA	BIT(15)
 /* Select PTP packets for Taking Snapshots */
-#define	PTP_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
+#define	PTP_TCR_SNAPTYPSEL_1	BIT(16)
+#define	PTP_GMAC4_TCR_SNAPTYPSEL_1	GENMASK(17, 16)
 /* Enable MAC address for PTP Frame Filtering */
 #define	PTP_TCR_TSENMACADDR	BIT(18)
 
-- 
2.7.4
