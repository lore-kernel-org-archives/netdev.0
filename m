From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/15] team: remove usage of netdev_set_master()
Date: Sun, 30 Dec 2012 12:58:12 +0100
Message-ID: <1356868702-8144-6-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:47599 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482Ab2L3L7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 06:59:38 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so5710696eek.11
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 03:59:37 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 918a901..3df5cc1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1055,10 +1055,11 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		}
 	}
 
-	err = netdev_set_master(port_dev, dev);
+	err = netdev_master_upper_dev_link(port_dev, dev);
 	if (err) {
-		netdev_err(dev, "Device %s failed to set master\n", portname);
-		goto err_set_master;
+		netdev_err(dev, "Device %s failed to set upper link\n",
+			   portname);
+		goto err_set_upper_link;
 	}
 
 	err = netdev_rx_handler_register(port_dev, team_handle_frame,
@@ -1091,9 +1092,9 @@ err_option_port_add:
 	netdev_rx_handler_unregister(port_dev);
 
 err_handler_register:
-	netdev_set_master(port_dev, NULL);
+	netdev_upper_dev_unlink(port_dev, dev);
 
-err_set_master:
+err_set_upper_link:
 	team_port_disable_netpoll(port);
 
 err_enable_netpoll:
@@ -1137,7 +1138,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
-	netdev_set_master(port_dev, NULL);
+	netdev_upper_dev_unlink(port_dev, dev);
 	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
-- 
1.8.0
