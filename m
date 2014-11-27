From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 21/21] rocker: Use logical operators on booleans
Date: Thu, 27 Nov 2014 11:40:26 +0100
Message-ID: <1417084826-9875-22-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:58666 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbaK0Kkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:55 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so18050554wib.5
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:54 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Silences various sparse warnings

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
new in v4
---
 drivers/net/ethernet/rocker/rocker.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 30687bf..fded127 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2404,17 +2404,17 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	}
 
 	priority = ROCKER_PRIORITY_UNKNOWN;
-	if (vlan_bridging & dflt & wild)
+	if (vlan_bridging && dflt && wild)
 		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_WILD;
-	else if (vlan_bridging & dflt & !wild)
+	else if (vlan_bridging && dflt && !wild)
 		priority = ROCKER_PRIORITY_BRIDGING_VLAN_DFLT_EXACT;
-	else if (vlan_bridging & !dflt)
+	else if (vlan_bridging && !dflt)
 		priority = ROCKER_PRIORITY_BRIDGING_VLAN;
-	else if (!vlan_bridging & dflt & wild)
+	else if (!vlan_bridging && dflt && wild)
 		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_WILD;
-	else if (!vlan_bridging & dflt & !wild)
+	else if (!vlan_bridging && dflt && !wild)
 		priority = ROCKER_PRIORITY_BRIDGING_TENANT_DFLT_EXACT;
-	else if (!vlan_bridging & !dflt)
+	else if (!vlan_bridging && !dflt)
 		priority = ROCKER_PRIORITY_BRIDGING_TENANT;
 
 	entry->key.priority = priority;
@@ -3010,9 +3010,9 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
 
-	if (learned & removing)
+	if (learned && removing)
 		br_fdb_external_learn_del(lw->dev, lw->addr, lw->vid);
-	else if (learned & !removing)
+	else if (learned && !removing)
 		br_fdb_external_learn_add(lw->dev, lw->addr, lw->vid);
 
 	kfree(work);
-- 
1.9.3
