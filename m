From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH] net/pch_gbe: Corrected the bug of PTP Rx filter
Date: Fri, 23 Mar 2012 11:20:49 +0900
Message-ID: <1332469249-2718-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 776bcf2..463e61c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -135,7 +135,10 @@ static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
 	u32 lo;
 
 	sk_filter = sk_run_filter(skb, ptp_filter);
-	if ((sk_filter != PTP_CLASS_V2) && (sk_filter != PTP_CLASS_V1))
+	if ((sk_filter != PTP_CLASS_V2_IPV4) &&
+	     (sk_filter != PTP_CLASS_V1_IPV4) &&
+	     (sk_filter != PTP_CLASS_V2_IPV6) &&
+	     (sk_filter != PTP_CLASS_V1_IPV6))
 		return 0;
 
 	offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
-- 
1.7.4.4
