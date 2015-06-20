From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] dsa: mv88x6xxx: Zero statistics counters
Date: Sat, 20 Jun 2015 21:31:29 +0200
Message-ID: <1434828689-11804-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60054 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932170AbbFTThZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 15:37:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zero the statistics counters when setting up the global
registers. Otherwise the counters will remain from the last boot if
the power has not been removed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---

This patch will only cleanly apply after the debug series.  There is
no actual dependency, so applying the patch with some fuzz will allow
it to be applied without the debug series.

 drivers/net/dsa/mv88e6xxx.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cb6c2711d6ea..fc73d809c292 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2061,6 +2061,12 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 				  0x9000 | (i << 8));
 	}
 
+	/* Clear the statistics counters for all ports */
+	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP, GLOBAL_STATS_OP_FLUSH_ALL);
+
+	/* Wait for the flush to complete. */
+	_mv88e6xxx_stats_wait(ds);
+
 	return 0;
 }
 
-- 
2.1.4
