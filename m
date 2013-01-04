From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V6 06/15] bridge: remove usage of netdev_set_master()
Date: Fri,  4 Jan 2013 09:48:54 +0100
Message-ID: <1357289343-817-7-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:45933 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab3ADIth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 03:49:37 -0500
Received: by mail-ee0-f50.google.com with SMTP id b45so8144002eek.9
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 00:49:34 -0800 (PST)
In-Reply-To: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_if.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1edd71d..2148d47 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -148,7 +148,7 @@ static void del_nbp(struct net_bridge_port *p)
 	netdev_rx_handler_unregister(dev);
 	synchronize_net();
 
-	netdev_set_master(dev, NULL);
+	netdev_upper_dev_unlink(dev, br->dev);
 
 	br_multicast_del_port(p);
 
@@ -364,7 +364,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p, GFP_KERNEL))))
 		goto err3;
 
-	err = netdev_set_master(dev, br->dev);
+	err = netdev_master_upper_dev_link(dev, br->dev);
 	if (err)
 		goto err4;
 
@@ -403,7 +403,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 
 err5:
-	netdev_set_master(dev, NULL);
+	netdev_upper_dev_unlink(dev, br->dev);
 err4:
 	br_netpoll_disable(p);
 err3:
-- 
1.8.0
