From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 10/16] net: dsa: mv88e6xxx: Only support EDSA tagging
Date: Fri, 27 May 2016 03:20:44 +0200
Message-ID: <1464312050-23023-11-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52563 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851AbcE0B1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:27:30 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The merged driver no longer offers the option to use DSA tagging. So
remove the code to setup the switch to do DSA tagging and hard code
the use of EDSA.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 492801a6398c..11845eccf670 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2725,11 +2725,8 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
 		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
 		    mv88e6xxx_6320_family(ps)) {
-			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
-				reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
-			else
-				reg |= PORT_CONTROL_FRAME_MODE_DSA;
-			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
+			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
+				PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		}
 
@@ -2737,7 +2734,6 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_priv_state *ps, int port)
 		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
 		    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
 		    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps)) {
-			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
 				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
-- 
2.8.1
