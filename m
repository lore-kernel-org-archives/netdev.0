From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 2/2] net: Disable NETIF_F_TSO_ECN when TSO is
 disabled
Date: Wed, 13 Apr 2011 01:47:15 +0100
Message-ID: <1302655635.2880.35.camel@bwh-desktop>
References: <1302655117.2880.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17054 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932693Ab1DMArS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 20:47:18 -0400
In-Reply-To: <1302655117.2880.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_TSO_ECN has no effect when TSO is disabled; this just means
that feature state will be accurately reported to user-space.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This one is silent; I'm not sure that it's worth mentioning as the
feature flag previously had no effect on its own anyway.

Ben.

 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6401fb5..c2ac599 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5208,6 +5208,10 @@ u32 netdev_fix_features(struct net_device *dev, u32 features)
 		features &= ~NETIF_F_ALL_TSO;
 	}
 
+	/* TSO ECN requires that TSO is present as well. */
+	if ((features & NETIF_F_ALL_TSO) == NETIF_F_TSO_ECN)
+		features &= ~NETIF_F_TSO_ECN;
+
 	/* Software GSO depends on SG. */
 	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
 		netdev_info(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

