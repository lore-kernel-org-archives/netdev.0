From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 3/9] net: Fix netdev_fix_features so that
 TSO_MANGLEID is only available with TSO
Date: Fri, 29 Apr 2016 15:43:21 -0700
Message-ID: <20160429224321.12418.72391.stgit@ahduyck-xeon-server>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32982 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbcD2Wn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:28 -0400
Received: by mail-pa0-f48.google.com with SMTP id zm5so56571610pac.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:27 -0700 (PDT)
In-Reply-To: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
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
