From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/15] team: remove usage of netdev_set_master()
Date: Tue, 14 Aug 2012 17:05:38 +0200
Message-ID: <1344956748-2099-6-git-send-email-jiri@resnulli.us>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ba10c46..dabddc5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1040,10 +1040,11 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
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
@@ -1076,9 +1077,9 @@ err_option_port_add:
 	netdev_rx_handler_unregister(port_dev);
 
 err_handler_register:
-	netdev_set_master(port_dev, NULL);
+	netdev_upper_dev_unlink(port_dev, dev);
 
-err_set_master:
+err_set_upper_link:
 	team_port_disable_netpoll(port);
 
 err_enable_netpoll:
@@ -1121,7 +1122,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
-	netdev_set_master(port_dev, NULL);
+	netdev_upper_dev_unlink(port_dev, dev);
 	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
-- 
1.7.10.4
