From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/15] bridge: remove usage of netdev_set_master()
Date: Sat, 29 Dec 2012 11:38:33 +0100
Message-ID: <1356777522-19652-7-git-send-email-jiri@resnulli.us>
References: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ea0-f182.google.com ([209.85.215.182]:36591 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780Ab2L2KjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 05:39:10 -0500
Received: by mail-ea0-f182.google.com with SMTP id a14so4699243eaa.41
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 02:39:09 -0800 (PST)
In-Reply-To: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_if.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 37fe693..742e467 100644
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
