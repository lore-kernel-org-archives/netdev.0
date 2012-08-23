From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] team: do not allow to add VLAN challenged port when vlan is used
Date: Thu, 23 Aug 2012 15:26:53 +0200
Message-ID: <1345728413-10298-4-git-send-email-jiri@resnulli.us>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, brouer@redhat.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:39327 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933236Ab2HWN1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:27:22 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr14so945258wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 06:27:21 -0700 (PDT)
In-Reply-To: <1345728413-10298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4010bcd..49629fb 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -989,6 +989,13 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		return -EBUSY;
 	}
 
+	if (port_dev->features & NETIF_F_VLAN_CHALLENGED &&
+	    vlan_uses_dev(dev)) {
+		netdev_err(dev, "Device %s is VLAN challenged and team device has VLAN set up\n",
+			   portname);
+		return -EPERM;
+	}
+
 	err = team_dev_type_check_change(dev, port_dev);
 	if (err)
 		return err;
-- 
1.7.11.4
