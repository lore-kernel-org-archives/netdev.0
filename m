From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible circular locking in current wireless-dev.git
Date: Sun, 3 Sep 2006 21:24:57 +0200
Message-ID: <20060903192457.GA2483@electric-eye.fr.zoreil.com>
References: <44FB03C0.5080204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, jkmaline@cc.hut.fi,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48578 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932138AbWICT2Q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 15:28:16 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44FB03C0.5080204@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger@lwfinger.net> :
> When booting the latest version of Linville's wireless-dev
> and starting my BCM4306 with WPA-PSK TKIP, the I get the
> following INFO printout that indicates a possible circular locking dependency
> involving 80211 and wpa_supplicant.

Please try the patch below that Xerbert Xu sent a few hours
ago on l-k and netdev:

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0834c2e..6f91518 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -238,9 +238,7 @@ void __netdev_watchdog_up(struct net_dev
 
 static void dev_watchdog_up(struct net_device *dev)
 {
-	netif_tx_lock_bh(dev);
 	__netdev_watchdog_up(dev);
-	netif_tx_unlock_bh(dev);
 }
 
 static void dev_watchdog_down(struct net_device *dev)

-- 

-- 
VGER BF report: U 0.50127
