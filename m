From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net] bond: Check length of IFLA_BOND_ARP_IP_TARGET attributes
Date: Thu, 27 Nov 2014 00:22:33 +0100
Message-ID: <a7c193909c30dbc19b4f279a3f7ba757107641d3.1417044113.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35323 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbaKZXWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 18:22:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 7f28fa10 ("bonding: add arp_ip_target netlink support")
Reported-by: John Fastabend <john.fastabend@gmail.com>
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/bonding/bond_netlink.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index c13d83e..45f09a6 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -225,7 +225,12 @@ static int bond_changelink(struct net_device *bond_dev,
 
 		bond_option_arp_ip_targets_clear(bond);
 		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
-			__be32 target = nla_get_be32(attr);
+			__be32 target;
+
+			if (nla_len(attr) < sizeof(target))
+				return -EINVAL;
+
+			target = nla_get_be32(attr);
 
 			bond_opt_initval(&newval, (__force u64)target);
 			err = __bond_opt_set(bond, BOND_OPT_ARP_TARGETS,
-- 
1.9.3
