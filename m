From: y@broadcom.com
Subject: [PATCH net-next 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Mon, 18 Feb 2013 15:15:20 +0200
Message-ID: <1365.53704874149$1361193345@news.gmane.org>
References: <y> <1361193320-11181-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1840 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982Ab3BRNPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 08:15:20 -0500
In-Reply-To: <1361193320-11181-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 net/ipv4/ip_gre.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index cdc31ac..31bc941 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1103,8 +1103,14 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 	tunnel->hlen = addend;
 	/* TCP offload with GRE SEQ is not supported. */
 	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
-		dev->features		|= NETIF_F_GSO_SOFTWARE;
-		dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
+		/* device supports enc gso offload*/
+		if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
+			dev->features		|= NETIF_F_TSO;
+			dev->hw_features	|= NETIF_F_TSO;
+		} else {
+			dev->features		|= NETIF_F_GSO_SOFTWARE;
+			dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
+		}
 	}
 
 	return mtu;
-- 
1.7.7.2
