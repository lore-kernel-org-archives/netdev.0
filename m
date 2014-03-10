From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/4 (v2)] stmmac: fix and better tune the default buffer sizes
Date: Mon, 10 Mar 2014 13:40:32 +0100
Message-ID: <1394455234-32021-3-git-send-email-peppe.cavallaro@st.com>
References: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:41378 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbaCJNMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 09:12:46 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 91B72240
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:08 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7850716535
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:42:08 +0000 (GMT)
In-Reply-To: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix and tune the default buffer sizes.
It reduces the default bufsize used by the driver from
4KiB to 1536 bytes.

Patch has been tested on both ARM and SH4 platform based.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

v2: adopt a default buffer size w/o using Koption.

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b418f94..5365836 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -92,8 +92,8 @@ static int tc = TC_DEFAULT;
 module_param(tc, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tc, "DMA threshold control value");
 
-#define DMA_BUFFER_SIZE	BUF_SIZE_4KiB
-static int buf_sz = DMA_BUFFER_SIZE;
+#define	DEFAULT_BUFSIZE	1536
+static int buf_sz = DEFAULT_BUFSIZE;
 module_param(buf_sz, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(buf_sz, "DMA buffer size");
 
@@ -136,8 +136,8 @@ static void stmmac_verify_args(void)
 		dma_rxsize = DMA_RX_SIZE;
 	if (unlikely(dma_txsize < 0))
 		dma_txsize = DMA_TX_SIZE;
-	if (unlikely((buf_sz < DMA_BUFFER_SIZE) || (buf_sz > BUF_SIZE_16KiB)))
-		buf_sz = DMA_BUFFER_SIZE;
+	if (unlikely((buf_sz < DEFAULT_BUFSIZE) || (buf_sz > BUF_SIZE_16KiB)))
+		buf_sz = DEFAULT_BUFSIZE;
 	if (unlikely(flow_ctrl > 1))
 		flow_ctrl = FLOW_AUTO;
 	else if (likely(flow_ctrl < 0))
@@ -901,10 +901,10 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 		ret = BUF_SIZE_8KiB;
 	else if (mtu >= BUF_SIZE_2KiB)
 		ret = BUF_SIZE_4KiB;
-	else if (mtu >= DMA_BUFFER_SIZE)
+	else if (mtu > DEFAULT_BUFSIZE)
 		ret = BUF_SIZE_2KiB;
 	else
-		ret = DMA_BUFFER_SIZE;
+		ret = DEFAULT_BUFSIZE;
 
 	return ret;
 }
-- 
1.7.4.4
