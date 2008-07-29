From: Komuro <komurojun-mbn@nifty.com>
Subject: RE: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Tue, 29 Jul 2008 21:53:15 +0900
Message-ID: <20080729215315.5a505fe7.komurojun-mbn@nifty.com>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758556AbYG2M5u@vger.kernel.org>
In-Reply-To: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Please try to comment out the "WARN_ON_ONCE"
at net/sched/sched_generic.c.


--- linux-2.6.27-rc1/net/sched/sch_generic.c.orig	2008-07-29 21:45:36.000000000 +0900
+++ linux-2.6.27-rc1/net/sched/sch_generic.c	2008-07-29 21:45:54.000000000 +0900
@@ -216,7 +216,6 @@ static void dev_watchdog(unsigned long a
 				printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
 				       dev->name, netdev_drivername(dev, drivername, 64));
 				dev->tx_timeout(dev);
-				WARN_ON_ONCE(1);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
 				       round_jiffies(jiffies +



>I should'nt be posting this, due to
>having  tainted modules(madwifi), but
>I figured I might as well:(below)
>
>[ 5000.986044] NETDEV WATCHDOG: wifi0: transmit timed out
>[ 5000.991959] ------------[ cut here ]------------
>[ 5000.991964] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x95/0xe7()

Best Regards
Komuro
