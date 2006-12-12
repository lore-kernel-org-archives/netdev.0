From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] bonding.h: "extern inline" -> "static inline"
Date: Tue, 12 Dec 2006 17:24:39 +0100
Message-ID: <20061212162439.GX28443@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, ctindel@users.sourceforge.net,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:3405 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751512AbWLLQY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 11:24:29 -0500
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" generates a warning with -Wmissing-prototypes and I'm
currently working on getting the kernel cleaned up for adding this to
the CFLAGS since it will help us to avoid a nasty class of runtime
errors.

If there are places that really need a forced inline, __always_inline
would be the correct solution.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/bonding/bonding.h |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.19-mm1/drivers/net/bonding/bonding.h.old	2006-12-12 15:57:43.000000000 +0100
+++ linux-2.6.19-mm1/drivers/net/bonding/bonding.h	2006-12-12 15:58:17.000000000 +0100
@@ -237,12 +237,13 @@
 #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
 					 BOND_ARP_VALIDATE_BACKUP)
 
-extern inline int slave_do_arp_validate(struct bonding *bond, struct slave *slave)
+static inline int slave_do_arp_validate(struct bonding *bond,
+					struct slave *slave)
 {
 	return bond->params.arp_validate & (1 << slave->state);
 }
 
-extern inline u32 slave_last_rx(struct bonding *bond, struct slave *slave)
+static inline u32 slave_last_rx(struct bonding *bond, struct slave *slave)
 {
 	if (slave_do_arp_validate(bond, slave))
 		return slave->last_arp_rx;

