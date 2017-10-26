From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/9] net: dsa: fix dsa_is_normal_port helper
Date: Thu, 26 Oct 2017 11:22:53 -0400
Message-ID: <20171026152259.3123-4-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44350 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932335AbdJZPXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:23:15 -0400
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to know if a port is of type user, dsa_is_normal_port checks
that the given port is not of type DSA nor CPU. This is not enough
because a port can be unused.

Without the previous fix, this caused the unused mv88e6xxx ports to be
configured in normal mode.

The ds->enabled_port_mask reports the user ports, so check this instead.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6b1bc1c8f7e2..4ad432ad2d40 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -273,7 +273,7 @@ static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
 
 static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
 {
-	return !dsa_is_cpu_port(ds, p) && !dsa_is_dsa_port(ds, p);
+	return !!(ds->enabled_port_mask & BIT(p));
 }
 
 static inline const struct dsa_port *dsa_to_port(struct dsa_switch *ds, int p)
-- 
2.14.3
