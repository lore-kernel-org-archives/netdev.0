From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 3/3] net: ipv4: fix waring -Wunused-variable
Date: Tue, 19 Feb 2013 18:43:12 +0800
Message-ID: <1361270592-19492-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: davem@davemloft.net, Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:10602 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758140Ab3BSKmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 05:42:40 -0500
In-Reply-To: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the vars ip_rt_gc_timeout is used only when
CONFIG_SYSCTL is selected.

move these vars into CONFIG_SYSCTL.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/route.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3bdd1b1..6e28514 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -117,15 +117,11 @@
 #define RT_GC_TIMEOUT (300*HZ)
 
 static int ip_rt_max_size;
-static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
-static int ip_rt_gc_interval __read_mostly  = 60 * HZ;
-static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
 static int ip_rt_redirect_number __read_mostly	= 9;
 static int ip_rt_redirect_load __read_mostly	= HZ / 50;
 static int ip_rt_redirect_silence __read_mostly	= ((HZ / 50) << (9 + 1));
 static int ip_rt_error_cost __read_mostly	= HZ;
 static int ip_rt_error_burst __read_mostly	= 5 * HZ;
-static int ip_rt_gc_elasticity __read_mostly	= 8;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
@@ -2423,6 +2419,11 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 }
 
 #ifdef CONFIG_SYSCTL
+static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
+static int ip_rt_gc_interval __read_mostly  = 60 * HZ;
+static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
+static int ip_rt_gc_elasticity __read_mostly	= 8;
+
 static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
-- 
1.7.11.7
