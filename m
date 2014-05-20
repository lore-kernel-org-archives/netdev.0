From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next v2 3/3] teaming: fix vlan_features computing
Date: Tue, 20 May 2014 08:29:45 +0200 (CEST)
Message-ID: <0a5534b35e7fffcb3fa0b25fc9a179b7c45b19ee.1400565116.git.mkubecek@suse.cz>
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
Received: from cantor2.suse.de ([195.135.220.15]:44358 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbaETG3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:29:46 -0400
In-Reply-To: <cover.1400565116.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__team_compute_features() uses netdev_increment_features() to
combine vlan_features of slaves into vlan_features of the team.
As netdev_increment_features() only adds most features and we
start with TEAM_VLAN_FEATURES, we can end up with features none
of the slaves provided.

Initialize vlan_features only with the flags which are both in
TEAM_VLAN_FEATURES and NETIF_F_ALL_FOR_ALL. Right now there is
no such feature so that we actually initialize vlan_features
with zero but stating it explicitely will make the code more
future proof.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/team/team.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 767fe61..9a9ce8d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -968,7 +968,7 @@ static void team_port_disable(struct team *team,
 static void __team_compute_features(struct team *team)
 {
 	struct team_port *port;
-	u32 vlan_features = TEAM_VLAN_FEATURES;
+	u32 vlan_features = TEAM_VLAN_FEATURES & NETIF_F_ALL_FOR_ALL;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
 
-- 
1.8.1.4
