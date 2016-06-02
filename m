From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 1/7] loopback: make use of NETIF_F_GSO_SOFTWARE
Date: Thu,  2 Jun 2016 15:05:38 -0300
Message-ID: <3a0c67d9d2c6ea0c0e06d161ceffafadb87fdead.1464888549.git.marcelo.leitner@gmail.com>
References: <cover.1464888549.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161414AbcFBSGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 14:06:02 -0400
In-Reply-To: <cover.1464888549.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_GSO_SOFTWARE was defined to list all GSO software types, so lets
make use of it in loopback code. Note that veth/vxlan/others already
uses it.

Within this patch series, this patch causes lo to pick up SCTP GSO feature
automatically (as it's added to NETIF_F_GSO_SOFTWARE) and thus avoiding
segmentation if possible.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/loopback.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index a400288cb37b9bfb6190f1bd7c64d02e97713956..6255973e3dda35fd41464ce51f0f9fb9f0b8364b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -169,10 +169,9 @@ static void loopback_setup(struct net_device *dev)
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	netif_keep_dst(dev);
-	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
+	dev->hw_features	= NETIF_F_GSO_SOFTWARE;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-		| NETIF_F_ALL_TSO
-		| NETIF_F_UFO
+		| NETIF_F_GSO_SOFTWARE
 		| NETIF_F_HW_CSUM
 		| NETIF_F_RXCSUM
 		| NETIF_F_SCTP_CRC
-- 
2.5.5
