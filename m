From: Wojciech Dubowik <Wojciech.Dubowik@neratec.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: Fix port forwarding mask
Date: Mon, 30 May 2016 11:35:44 +0200
Message-ID: <1464600944-30782-1-git-send-email-Wojciech.Dubowik@neratec.com>
Cc: netdev@vger.kernel.org,
	Wojciech Dubowik <Wojciech.Dubowik@neratec.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:32564 "EHLO mail.neratec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbcE3Jpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 05:45:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Port's vlan table is specified by bit mask and not by number.
Only 4.4.x kernels are affected.

Signed-off-by: Wojciech Dubowik <Wojciech.Dubowik@neratec.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2dea39b..3e074d4 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2150,7 +2150,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * database, and allow every port to egress frames on all other ports.
 	 */
 	reg = BIT(ps->num_ports) - 1; /* all ports */
-	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~port);
+	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~BIT(port));
 	if (ret)
 		goto abort;
 
-- 
1.9.1
