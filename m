From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] dsa: fix 88e6xxx statistics counter snapshotting
Date: Fri, 3 Jul 2009 11:26:48 +0200
Message-ID: <20090703092648.GM19647@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, Stephane.Contri@grassvalley.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:39885 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbZGCJRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 05:17:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Contri <Stephane.Contri@grassvalley.com>

The bit that tells us whether a statistics counter snapshot operation
has completed is located in the GLOBAL register block, not in the
GLOBAL2 register block, so fix up mv88e6xxx_stats_wait() to poll the
right register address.

Signed-off-by: Stephane Contri <Stephane.Contri@grassvalley.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Cc: stable@kernel.org

diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index 4e4d8b5..efe661a 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -418,7 +418,7 @@ static int mv88e6xxx_stats_wait(struct dsa_switch *ds)
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		ret = REG_READ(REG_GLOBAL2, 0x1d);
+		ret = REG_READ(REG_GLOBAL, 0x1d);
 		if ((ret & 0x8000) == 0)
 			return 0;
 	}
