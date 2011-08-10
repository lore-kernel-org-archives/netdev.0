From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/2] bonding: implement get_tx_queues rtnk_link_op
Date: Wed, 10 Aug 2011 18:09:44 +0200
Message-ID: <1312992585-1201-2-git-send-email-jpirko@redhat.com>
References: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab1HJQJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 12:09:59 -0400
In-Reply-To: <1312992585-1201-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vonding device is created via rtnl, it is created with default number
of rx/tx queues. This patch implements callback in bonding so the
correct value (previously specified by bonding module param) is used.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 38a83ac..854aa8d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4828,11 +4828,20 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int bond_get_tx_queues(struct net *net, struct nlattr *tb[],
+			      unsigned int *num_queues,
+			      unsigned int *real_num_queues)
+{
+	*num_queues = tx_queues;
+	return 0;
+}
+
 static struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.kind		= "bond",
 	.priv_size	= sizeof(struct bonding),
 	.setup		= bond_setup,
 	.validate	= bond_validate,
+	.get_tx_queues	= bond_get_tx_queues,
 };
 
 /* Create a new bond based on the specified name and bonding parameters.
-- 
1.7.6

