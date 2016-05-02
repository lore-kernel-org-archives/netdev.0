From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 3/8] net: Fix netdev_fix_features so that
 TSO_MANGLEID is only available with TSO
Date: Mon, 02 May 2016 09:38:24 -0700
Message-ID: <20160502163824.11809.64253.stgit@ahduyck-xeon-server>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35216 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbcEBQi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:26 -0400
Received: by mail-pf0-f181.google.com with SMTP id 77so48212018pfv.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:26 -0700 (PDT)
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we will strip the TSO_MANGLEID bit if TSO is
not present.  This way we will also handle ECN correctly of TSO is not
present.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/dev.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 673d1f118bfb..e98ba63fe280 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6721,6 +6721,10 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_TSO6;
 	}
 
+	/* TSO with IPv4 ID mangling requires IPv4 TSO be enabled */
+	if ((features & NETIF_F_TSO_MANGLEID) && !(features & NETIF_F_TSO))
+		features &= ~NETIF_F_TSO_MANGLEID;
+
 	/* TSO ECN requires that TSO is present as well. */
 	if ((features & NETIF_F_ALL_TSO) == NETIF_F_TSO_ECN)
 		features &= ~NETIF_F_TSO_ECN;
