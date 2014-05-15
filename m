From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix out of range parameters for bond_intmax_tbl
Date: Thu, 15 May 2014 13:35:23 +0200
Message-ID: <1400153723-8031-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbaEOLkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 07:40:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've missed to add a NULL entry to the bond_intmax_tbl when I introduced
it with the conversion of arp_interval so add it now.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>

Fixes: 7bdb04ed0dbf ("bonding: convert arp_interval to use the new
option API")
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 724e30fa20b9..832070298446 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -125,6 +125,7 @@ static const struct bond_opt_value bond_fail_over_mac_tbl[] = {
 static const struct bond_opt_value bond_intmax_tbl[] = {
 	{ "off",     0,       BOND_VALFLAG_DEFAULT},
 	{ "maxval",  INT_MAX, BOND_VALFLAG_MAX},
+	{ NULL,      -1,      0}
 };
 
 static const struct bond_opt_value bond_lacp_rate_tbl[] = {
-- 
1.8.5.3
