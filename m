From: Aaro Koskinen <aaro.koskinen@nsn.com>
Subject: [PATCH] drivers: net: ethernet: octeon_mgmt: fix a compiler warning
Date: Mon,  8 Sep 2014 18:01:53 +0300
Message-ID: <1410188513-2541-1-git-send-email-aaro.koskinen@nsn.com>
Cc: Aaro Koskinen <aaro.koskinen@nsn.com>
To: netdev@vger.kernel.org, David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:36944 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaIHPDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 11:03:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following compiler warning:

drivers/net/ethernet/octeon/octeon_mgmt.c: In function 'octeon_mgmt_clean_tx_buffers':
drivers/net/ethernet/octeon/octeon_mgmt.c:295:4: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
    u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
    ^

Signed-off-by: Aaro Koskinen <aaro.koskinen@nsn.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 979c698..a422930 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -290,9 +290,11 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
 		/* Read the hardware TX timestamp if one was recorded */
 		if (unlikely(re.s.tstamp)) {
 			struct skb_shared_hwtstamps ts;
+			u64 ns;
+
 			memset(&ts, 0, sizeof(ts));
 			/* Read the timestamp */
-			u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
+			ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
 			/* Remove the timestamp from the FIFO */
 			cvmx_write_csr(CVMX_MIXX_TSCTL(p->port), 0);
 			/* Tell the kernel about the timestamp */
-- 
2.1.0
