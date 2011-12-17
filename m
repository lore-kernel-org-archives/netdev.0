From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] gianfar: Reject out-of-range RX NFC locations
Date: Sat, 17 Dec 2011 01:05:27 +0000
Message-ID: <1324083927.2798.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6079 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752496Ab1LQBFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 20:05:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver only uses location values to maintain an ordered
list of filters.  There is nothing to stop the list becoming longer
than the filer hardware can support - the driver will report an error,
but will not roll back the change!

Make it reject location values >= MAX_FILER_IDX, consistent with the
range that gfar_get_cls_all() reports.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
[Re-sent to what I hope is a current address for Sebastian.]

This has not been tested in any way, as I don't have a suitable compiler
installed.  Sebastian, please could you review this?

Ben.

 drivers/net/ethernet/freescale/gianfar_ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 5890f4b..5a3b2e5 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1692,8 +1692,9 @@ static int gfar_set_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 		ret = gfar_set_hash_opts(priv, cmd);
 		break;
 	case ETHTOOL_SRXCLSRLINS:
-		if (cmd->fs.ring_cookie != RX_CLS_FLOW_DISC &&
-			cmd->fs.ring_cookie >= priv->num_rx_queues) {
+		if ((cmd->fs.ring_cookie != RX_CLS_FLOW_DISC &&
+		     cmd->fs.ring_cookie >= priv->num_rx_queues) ||
+		    cmd->fs.location >= MAX_FILER_IDX) {
 			ret = -EINVAL;
 			break;
 		}
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
