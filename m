From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: forbid incorrect fall-through in notifier
Date: Wed, 23 Apr 2014 14:17:55 +0200
Message-ID: <1398255475-9541-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34364 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbaDWMR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 08:17:58 -0400
Received: by mail-wi0-f175.google.com with SMTP id cc10so4783646wib.14
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 05:17:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two breaks missing there. The result is that userspace
receives multiple messages which might be confusing.

Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 33008c1..767fe61 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2834,8 +2834,10 @@ static int team_device_event(struct notifier_block *unused,
 	case NETDEV_UP:
 		if (netif_carrier_ok(dev))
 			team_port_change_check(port, true);
+		break;
 	case NETDEV_DOWN:
 		team_port_change_check(port, false);
+		break;
 	case NETDEV_CHANGE:
 		if (netif_running(port->dev))
 			team_port_change_check(port,
-- 
1.9.0
