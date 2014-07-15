From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: fix bond_option_mode_set warning
Date: Tue, 15 Jul 2014 16:08:57 +0200
Message-ID: <1405433337-8806-1-git-send-email-nikolay@redhat.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984AbaGOOJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 10:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the conversion to "static" functions this one got left out, only its
prototype was converted, thus resulting in:
drivers/net/bonding//bond_options.c:674:5: warning: symbol
'bond_option_mode_set' was not declared. Should it be static?

Fix it by making it static and also break the line in two as it was too
long.

CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 540e0167bf24..124a8135e139 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -671,7 +671,8 @@ const struct bond_option *bond_opt_get(unsigned int option)
 	return &bond_opts[option];
 }
 
-int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
+static int bond_option_mode_set(struct bonding *bond,
+				const struct bond_opt_value *newval)
 {
 	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
-- 
1.9.3
