From: David Decotigny <decot@google.com>
Subject: [PATCHv3 6/7] tulip/de2104x: don't report different speeds depending on port type
Date: Wed, 27 Apr 2011 18:27:22 -0700
Message-ID: <1303954043-17440-7-git-send-email-decot__24746.9443049797$1303954213$gmane$org@google.com>
References: <1303954043-17440-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:27029 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab1D1B1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 21:27:51 -0400
In-Reply-To: <1303954043-17440-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial driver reports different speeds depending on the port being
used. This patch advertises the speed to be 10Mbps in any case, which
is what it actually is on the wire.

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/tulip/de2104x.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index ab78e1d..46d5a1b 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1518,18 +1518,17 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 	switch (de->media_type) {
 	case DE_MEDIA_AUI:
 		ecmd->port = PORT_AUI;
-		ethtool_cmd_speed_set(ecmd, 5);
 		break;
 	case DE_MEDIA_BNC:
 		ecmd->port = PORT_BNC;
-		ethtool_cmd_speed_set(ecmd, 2);
 		break;
 	default:
 		ecmd->port = PORT_TP;
-		ethtool_cmd_speed_set(ecmd, SPEED_10);
 		break;
 	}
 
+	ethtool_cmd_speed_set(ecmd, 10);
+
 	if (dr32(MacMode) & FullDuplex)
 		ecmd->duplex = DUPLEX_FULL;
 	else
@@ -1549,11 +1548,8 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 {
 	u32 new_media;
 	unsigned int media_lock;
-	u32 speed = ethtool_cmd_speed(ecmd);
 
-	if (speed != SPEED_10 && speed != 5 && speed != 2)
-		return -EINVAL;
-	if (de->de21040 && speed == 2)
+	if (ethtool_cmd_speed(ecmd) != 10)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
-- 
1.7.3.1

