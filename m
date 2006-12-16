From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/4][TG3]: Assign tp->link_config.orig_* values.
Date: Fri, 15 Dec 2006 22:48:22 -0800
Message-ID: <1166251702.30429.9.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1078 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030590AbWLPF6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 00:58:54 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Assign tp->link_config.orig_* values.

tp->link_config.orig_* values must be assigned during
tg3_set_settings() because these values will be used to setup the
link speed during tg3_open().  Without these assignments, the link
speed settings will be all messed by if tg3_set_settings() is called
when the device is down.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 571320a..d01538e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7981,6 +7981,10 @@ static int tg3_set_settings(struct net_d
 		tp->link_config.duplex = cmd->duplex;
   	}
 
+	tp->link_config.orig_speed = tp->link_config.speed;
+	tp->link_config.orig_duplex = tp->link_config.duplex;
+	tp->link_config.orig_autoneg = tp->link_config.autoneg;
+
 	if (netif_running(dev))
 		tg3_setup_phy(tp, 1);
 


