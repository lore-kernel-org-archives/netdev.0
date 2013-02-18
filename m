From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Mon, 18 Feb 2013 15:39:51 +0200
Message-ID: <1361194791-11493-2-git-send-email-dmitry@broadcom.com>
References: <1361194791-11493-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4448 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725Ab3BRNjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 08:39:55 -0500
In-Reply-To: <1361194791-11493-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
