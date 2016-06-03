From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 04/17] net: dsa: tag_{e}dsa.c: Remove dependency on platform data
Date: Fri,  3 Jun 2016 18:44:03 +0200
Message-ID: <1464972256-10408-5-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58722 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120AbcFCQvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:51:08 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The platform data nr_chips is used when validating a received packet,
to ensure it comes from a know switch chip. The number of possible
switches is limited to DSA_MAX_SWITCHES, so use this as the first
validation step. The new binding allows holes in the dst->ds[] array,
so also ensure ensure there is a valid dsa_switch for this packet.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/tag_dsa.c  | 6 +++++-
 net/dsa/tag_edsa.c | 6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index aa780e4ac0bd..f9832f097681 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -107,9 +107,13 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * Check that the source device exists and that the source
 	 * port is a registered DSA port.
 	 */
-	if (source_device >= dst->pd->nr_chips)
+	if (source_device >= DSA_MAX_SWITCHES)
 		goto out_drop;
+
 	ds = dst->ds[source_device];
+	if (!ds)
+		goto out_drop;
+
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 2288c8098c42..3890aac8190f 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -120,9 +120,13 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	 * Check that the source device exists and that the source
 	 * port is a registered DSA port.
 	 */
-	if (source_device >= dst->pd->nr_chips)
+	if (source_device >= DSA_MAX_SWITCHES)
 		goto out_drop;
+
 	ds = dst->ds[source_device];
+	if (!ds)
+		goto out_drop;
+
 	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
 		goto out_drop;
 
-- 
2.8.1
