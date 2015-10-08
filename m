From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Prevent UDP 4-tuple configurations on older adapters
Date: Thu, 8 Oct 2015 16:19:01 +0300
Message-ID: <1444310341-9970-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dkiser@godaddy.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27651 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755414AbbJHNTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:19:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configuring 4-tuple RSS hsahing for UDP
[E.g., by using `ethtool -N <interface> rx-flow-hash udp4 sdfn']
on a 57710/57711 adapter would cause it to assert as HW does not
support such a configuration.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index aeb7ce6..be628bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3351,6 +3351,13 @@ static int bnx2x_set_rss_flags(struct bnx2x *bp, struct ethtool_rxnfc *info)
 			udp_rss_requested = 0;
 		else
 			return -EINVAL;
+
+		if (CHIP_IS_E1x(bp) && udp_rss_requested) {
+			DP(BNX2X_MSG_ETHTOOL,
+			   "57710, 57711 boards don't support RSS according to UDP 4-tuple\n");
+			return -EINVAL;
+		}
+
 		if ((info->flow_type == UDP_V4_FLOW) &&
 		    (bp->rss_conf_obj.udp_rss_v4 != udp_rss_requested)) {
 			bp->rss_conf_obj.udp_rss_v4 = udp_rss_requested;
-- 
1.9.3
