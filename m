From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/2] net: dsa: Error out on tagging protocol mismatches
Date: Thu, 23 Oct 2014 01:35:17 +0200
Message-ID: <1414020918-20903-2-git-send-email-andrew@lunn.ch>
References: <1414020918-20903-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42327 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932666AbaJVXgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 19:36:33 -0400
In-Reply-To: <1414020918-20903-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is a mismatch between enabled tagging protocols and the
protocol the switch supports, error out, rather than continue with a
situation which is unlikely to work.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
cc: alexander.h.duyck@intel.com
---
 net/dsa/dsa.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 22f34cf4cb27..8a31bd81a315 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -175,7 +175,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 			break;
 #endif
 		default:
-			break;
+			ret = -ENOPROTOOPT;
+			goto out;
 		}
 
 		dst->tag_protocol = drv->tag_protocol;
-- 
2.1.1
