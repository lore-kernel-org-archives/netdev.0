From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb3: Update VLAN extraction stats in the GRO path
Date: Fri,  1 Feb 2013 15:33:47 +0530
Message-ID: <1359713027-31653-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11975 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317Ab3BAKJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 05:09:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Divy Le Ray <divy@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 9096dc0..9d67eb7 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2130,8 +2130,10 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 
 	skb_record_rx_queue(skb, qs - &adap->sge.qs[pi->first_qset]);
 
-	if (cpl->vlan_valid)
+	if (cpl->vlan_valid) {
+		qs->port_stats[SGE_PSTAT_VLANEX]++;
 		__vlan_hwaccel_put_tag(skb, ntohs(cpl->vlan));
+	}
 	napi_gro_frags(&qs->napi);
 }
 
-- 
1.7.1
