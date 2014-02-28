From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2] iplink_bond_slave: show mii_status only once
Date: Fri, 28 Feb 2014 14:58:15 +0100 (CET)
Message-ID: <20140228135815.2C101E66B4@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60455 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897AbaB1N6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 08:58:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With "ip -d link show", bonding slave mii status is displayed
twice, once as a number and once as a name.

Fixes: 730d3f61 ("iplink: add support for bonding slave")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink_bond_slave.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index bb4e1d6..8f3fc6c 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -43,7 +43,6 @@ static void print_slave_mii_status(FILE *f, struct rtattr *tb)
 {
 	unsigned int status = rta_getattr_u8(tb);
 
-	fprintf(f, "mii_status %d ", status);
 	if (status >= sizeof(slave_mii_status) / sizeof(slave_mii_status[0]))
 		fprintf(f, "mii_status %d ", status);
 	else
-- 
1.8.1.4
