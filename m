From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/6] bond: Get the rtnl_link_ops support correct
Date: Fri, 30 Oct 2009 02:58:54 -0700
Message-ID: <m1y6mtqk2p.fsf_-_@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<1256861906-5059-5-git-send-email-ebiederm@xmission.com>
	<4AEAA403.7080204@trash.net> <m1eiols0a4.fsf@fess.ebiederm.org>
	<4AEAB2F1.5070200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53358 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743AbZJ3J64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 05:58:56 -0400
In-Reply-To: <4AEAB2F1.5070200@trash.net> (Patrick McHardy's message of "Fri\, 30 Oct 2009 10\:33\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Don't call rtnl_link_unregister if rtnl_link_register fails
- Set .priv_size so we aren't stomping on uninitialized memory
  when we use netdev_priv, on bond devices created with
  ip link add type bond.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fed44e6..0ef051c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5004,6 +5004,7 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.kind		= "bond",
+	.priv_size	= sizeof(struct bonding),
 	.setup		= bond_setup,
 	.validate	= bond_validate,
 };
@@ -5105,7 +5106,7 @@ static int __init bonding_init(void)
 
 	res = rtnl_link_register(&bond_link_ops);
 	if (res)
-		goto err;
+		goto err_link;
 
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(&init_net, NULL);
@@ -5124,6 +5125,7 @@ out:
 	return res;
 err:
 	rtnl_link_unregister(&bond_link_ops);
+err_link:
 	unregister_pernet_gen_subsys(bond_net_id, &bond_net_ops);
 	goto out;
 
-- 
1.6.3.1.54.g99dd.dirty

