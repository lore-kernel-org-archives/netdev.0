From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: allow TSO being set on master
Date: Wed, 25 Feb 2015 19:52:11 +0100
Message-ID: <1424890331-6850-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jprochaz@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:39551 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbbBYSwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:52:16 -0500
Received: by wggx12 with SMTP id x12so5564461wgg.6
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 10:52:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows TSO being set/unset on the master, so that GSO
segmentation is done after team layer.

Similar patch is present for bonding:
	b0ce3508b25e ("bonding: allow TSO being set on bonding master")
and bridge:
	f902e8812ef6 ("bridge: Add ability to enable TSO")

Suggested-by: Jiri Prochazka <jprochaz@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 0e62274..a7d163b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1937,6 +1937,9 @@ static netdev_features_t team_fix_features(struct net_device *dev,
 						     mask);
 	}
 	rcu_read_unlock();
+
+	features = netdev_add_tso_features(features, mask);
+
 	return features;
 }
 
-- 
1.9.3
