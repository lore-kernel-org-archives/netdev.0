From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next v2 2/3] bonding: fix vlan_features computing
Date: Tue, 20 May 2014 08:29:35 +0200 (CEST)
Message-ID: <b674454b3c315ebc69de6705f4db9cdaa900f7c8.1400565116.git.mkubecek@suse.cz>
References: <20140507.140846.1449010184057650775.davem@davemloft.net>
	<cover.1400565116.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Michal Miroslaw <mirq-linux@rere.qmqm.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44350 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbaETG3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:29:36 -0400
In-Reply-To: <cover.1400565116.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_compute_features() uses netdev_increment_features() to
combine vlan_features of slaves into vlan_features of the bond.
As netdev_increment_features() only adds most features and we
start with BOND_VLAN_FEATURES, we can end up with features none
of the slaves provided.

If there is at least one slave, initialize vlan_features only
with the flags in NETIF_F_ALL_FOR_ALL. Right now there is none
in BOND_VLAN_FEATURES but stating it explicitely will make the
code more future proof.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7123205..9071139 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1038,6 +1038,7 @@ static void bond_compute_features(struct bonding *bond)
 
 	if (!bond_has_slaves(bond))
 		goto done;
+	vlan_features &= NETIF_F_ALL_FOR_ALL;
 
 	bond_for_each_slave(bond, slave, iter) {
 		vlan_features = netdev_increment_features(vlan_features,
-- 
1.8.1.4
