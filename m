From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 1/8] gianfar: Reject out-of-range RX NFC
 locations
Date: Tue, 3 Jan 2012 21:59:30 +0000
Message-ID: <1325627970.2832.33.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.poehn@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36752 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754125Ab2ACV7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 16:59:33 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver only uses location values to maintain an ordered
list of filters.  Make it reject location values >=3D MAX_FILER_IDX
passed to the ETHTOOL_SRXCLSRLINS command, consistent with the range
it reports for the ETHTOOL_GRXCLSRLALL command.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: Sebastian P=C3=B6hn <sebastian.poehn@googlemail.com>
---
Sebastian, I took your private reply as an ack; please shout if that's
wrong.

Ben.

 drivers/net/ethernet/freescale/gianfar_ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers=
/net/ethernet/freescale/gianfar_ethtool.c
index 5890f4b..5a3b2e5 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1692,8 +1692,9 @@ static int gfar_set_nfc(struct net_device *dev, s=
truct ethtool_rxnfc *cmd)
 		ret =3D gfar_set_hash_opts(priv, cmd);
 		break;
 	case ETHTOOL_SRXCLSRLINS:
-		if (cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
-			cmd->fs.ring_cookie >=3D priv->num_rx_queues) {
+		if ((cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
+		     cmd->fs.ring_cookie >=3D priv->num_rx_queues) ||
+		    cmd->fs.location >=3D MAX_FILER_IDX) {
 			ret =3D -EINVAL;
 			break;
 		}
--=20
1.7.4.4



--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
