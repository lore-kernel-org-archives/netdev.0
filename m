From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 2/2] team:  Use new sync_multiple api to sync devices adressess.
Date: Mon, 15 Apr 2013 15:09:57 -0400
Message-ID: <1366052997-12435-3-git-send-email-vyasevic@redhat.com>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541Ab3DOTnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 15:43:01 -0400
In-Reply-To: <1366052997-12435-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Team drivers attempts to sync addresses to each of of the port
devices; however, the current api doesn't do anything for anything
after the first device.  Switch to using the new api that will
actually sync the addresses to all ports.

CC: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/team/team.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bf34192..33d89f8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1491,8 +1491,8 @@ static void team_set_rx_mode(struct net_device *dev)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list) {
-		dev_uc_sync(port->dev, dev);
-		dev_mc_sync(port->dev, dev);
+		dev_uc_sync_multiple(port->dev, dev);
+		dev_mc_sync_multiple(port->dev, dev);
 	}
 	rcu_read_unlock();
 }
-- 
1.7.7.6
