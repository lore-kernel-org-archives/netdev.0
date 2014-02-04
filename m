From: Dmitry Kravkov <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix L2-GRE TCP issues
Date: Tue, 4 Feb 2014 17:43:03 +0200
Message-ID: <1391528583-22935-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mschmidt@redhat.com>, Dmitry Kravkov <dmitry@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:29770 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaBDPnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 10:43:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring GRE tunnel using OVS, tcp stream is distributed over
all RSS queues which may cause TCP reordering. It happens since OVS
uses L2GRE protocol when kernel gre uses IPGRE.
Patch defaults gre tunnel to L2GRE which allows proper RSS for L2GRE
packets and (implicitly) disables RSS for IPGRE traffic.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 17d1689..bfc58d4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -936,7 +936,7 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
 
-	start_params->gre_tunnel_mode = IPGRE_TUNNEL;
+	start_params->gre_tunnel_mode = L2GRE_TUNNEL;
 	start_params->gre_tunnel_rss = GRE_INNER_HEADERS_RSS;
 
 	return bnx2x_func_state_change(bp, &func_params);
-- 
1.8.5.3
