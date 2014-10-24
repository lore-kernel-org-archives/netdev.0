From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 2/2] dsa: mv88e6171: Fix tagging protocol/Kconfig
Date: Fri, 24 Oct 2014 23:44:05 +0200
Message-ID: <1414187045-8326-3-git-send-email-andrew@lunn.ch>
References: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43496 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775AbaJXVpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 17:45:05 -0400
In-Reply-To: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6171 can support two different tagging protocols, DSA and
EDSA. The switch driver structure only allows one protocol to be
enumerated, and DSA was chosen. However the Kconfig entry ensures the
EDSA tagging code is built. With a minimal configuration, we then end
up with a mismatch. The probe is successful, EDSA tagging is used, but
the switch is configured for DSA, resulting in mangled packets.

Change the switch driver structure to enumerate EDSA, fixing the
mismatch.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 42f272539487 ("net: DSA: Marvell mv88e6171 switch driver")
---
 drivers/net/dsa/mv88e6171.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1020a7af67cf..78d8e876f3aa 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -395,7 +395,7 @@ static int mv88e6171_get_sset_count(struct dsa_switch *ds)
 }
 
 struct dsa_switch_driver mv88e6171_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_DSA,
+	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6171_probe,
 	.setup			= mv88e6171_setup,
-- 
2.1.1
