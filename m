From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] team: unsyc the devices addresses when port is removed
Date: Thu,  7 Mar 2013 12:59:25 -0500
Message-ID: <1362679165-31203-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060Ab3CGR7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 12:59:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a team port is removed, unsync all devices addresses that may have
been synched to the port devices.

CC: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/team/team.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..bf34192 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1138,6 +1138,8 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	netdev_upper_dev_unlink(port_dev, dev);
 	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
+	dev_uc_unsync(port_dev, dev);
+	dev_mc_unsync(port_dev, dev);
 	dev_close(port_dev);
 	team_port_leave(team, port);
 
-- 
1.7.7.6
