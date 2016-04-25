From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/8] net: Fix netdev_fix_features so that
 TSO_MANGLEID is only available with TSO
Date: Mon, 25 Apr 2016 11:31:14 -0700
Message-ID: <20160425183114.11331.97539.stgit@ahduyck-xeon-server>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33311 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbcDYSbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:31:16 -0400
Received: by mail-pf0-f175.google.com with SMTP id 206so20644275pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:31:16 -0700 (PDT)
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
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
index d6d9f286c4e1..6a5ef49ed1ab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6720,6 +6720,10 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_TSO6;
 	}
 
+	/* TSO with IPv4 ID mangling requires IPv4 TSO be enabled */
+	if ((features & NETIF_F_TSO_MANGLEID) && !(features & NETIF_F_TSO))
+		features &= ~NETIF_F_TSO_MANGLEID;
+
 	/* TSO ECN requires that TSO is present as well. */
 	if ((features & NETIF_F_ALL_TSO) == NETIF_F_TSO_ECN)
 		features &= ~NETIF_F_TSO_ECN;
