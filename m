From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix VF driver off-by-one bug when setting
 ethtool -C ethX rx-frames
Date: Wed, 14 Jun 2017 09:11:31 -0700
Message-ID: <20170614161131.GA1383@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        weilin.chang@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0052.outbound.protection.outlook.com ([104.47.40.52]:41724
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752099AbdFNQLl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 12:11:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilin Chang <weilin.chang@cavium.com>

Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 53856af..28ecda3 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1808,7 +1808,7 @@ oct_cfg_rx_intrcnt(struct lio *lio,
 			    (octeon_read_csr64(
 				 oct, CN23XX_VF_SLI_OQ_PKT_INT_LEVELS(q_no)) &
 			     (0x3fffff00000000UL)) |
-				rx_max_coalesced_frames);
+				(rx_max_coalesced_frames - 1));
 			/*consider writing to resend bit here*/
 		}
 		intrmod->rx_frames = rx_max_coalesced_frames;
