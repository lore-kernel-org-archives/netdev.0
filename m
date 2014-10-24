From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 1/2] net: dsa: Error out on tagging protocol mismatches
Date: Fri, 24 Oct 2014 23:44:04 +0200
Message-ID: <1414187045-8326-2-git-send-email-andrew@lunn.ch>
References: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43499 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522AbaJXVpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 17:45:07 -0400
In-Reply-To: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is a mismatch between enabled tagging protocols and the
protocol the switch supports, error out, rather than continue with a
situation which is unlikely to work.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
cc: alexander.h.duyck@intel.com
---

v2: Handle the use case of DSA_TAG_PROTO_NONE

 net/dsa/dsa.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 22f34cf4cb27..6317b41c99b0 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -174,8 +174,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 			dst->rcv = brcm_netdev_ops.rcv;
 			break;
 #endif
-		default:
+		case DSA_TAG_PROTO_NONE:
 			break;
+		default:
+			ret = -ENOPROTOOPT;
+			goto out;
 		}
 
 		dst->tag_protocol = drv->tag_protocol;
-- 
2.1.1
