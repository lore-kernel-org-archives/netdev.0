From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: prevent false carrier sense detection
Date: Wed, 27 Aug 2014 08:20:04 +0200
Message-ID: <1409120404-20414-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45703 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932740AbaH0GUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:20:11 -0400
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7R6HuXm022997
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:20:09 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1p152318nc-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:20:09 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3369531
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:19:57 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 527BD16B79
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:20:07 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to w/a a problem that happens on some boxes when run at 10Mbps
Half duplex mode.

During the transmission the CSR signal is asserted for some time and the frames
aborted because of carrier sense error.
This is reported by MMC HW counter: txcarrier signal.
This actually is a false carrier so the frames are good and there is no reason
to ask for dropping them.

This patch so disables the Carrier Sense During Transmission
and this means that the MAC transmitter ignore the CRS signal
during frame transmission in Half-Duplex mode.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Acked-by: Vince Bridgers <vbridgers2013@gmail.com>
Acked-by: Ley Foon Tan <lftan@altera.com>
Acked-by: Chen-Yu Tsai <wens@csie.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 71b5419..64d8f56 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -153,7 +153,7 @@ enum inter_frame_gap {
 #define GMAC_CONTROL_RE		0x00000004	/* Receiver Enable */
 
 #define GMAC_CORE_INIT (GMAC_CONTROL_JD | GMAC_CONTROL_PS | GMAC_CONTROL_ACS | \
-			GMAC_CONTROL_BE)
+			GMAC_CONTROL_BE | GMAC_CONTROL_DCRS)
 
 /* GMAC Frame Filter defines */
 #define GMAC_FRAME_FILTER_PR	0x00000001	/* Promiscuous Mode */
-- 
1.7.4.4
