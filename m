From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] hostap: remove netif_stop_queue from init
Date: Fri, 17 Dec 2010 23:27:50 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1012172324340.24976@math.ut.ee>
References: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee> <20101209.195315.193716225.davem@davemloft.net> <alpine.SOC.1.00.1012100918300.15996@math.ut.ee> <20101210.094747.193727608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: j@w1.fi, netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:50388 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570Ab0LQV1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 16:27:52 -0500
In-Reply-To: <20101210.094747.193727608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix runtime warning with backtrace from hostap by removing 
netif_stop_queue() call before register_netdev. Tested to work fine on 
hostap_pci Prism 2.5.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 25a2722..1d9aed6 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -891,7 +891,6 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	SET_ETHTOOL_OPS(dev, &prism2_ethtool_ops);
 
-	netif_stop_queue(dev);
 }
 
 static int hostap_enable_hostapd(local_info_t *local, int rtnl_locked)

-- 
Meelis Roos (mroos@linux.ee)
