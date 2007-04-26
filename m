From: akpm@linux-foundation.org
Subject: [patch 09/15] SPIN_LOCK_UNLOCKED cleanup in drivers/atm, net
Date: Thu, 26 Apr 2007 00:27:28 -0700
Message-ID: <200704260727.l3Q7RSwf023967@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	milindchoudhary@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:41577 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933585AbXDZH7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:59:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milind Arun Choudhary <milindchoudhary@gmail.com>

SPIN_LOCK_UNLOCKED cleanup,use __SPIN_LOCK_UNLOCKED instead

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/atmtcp.c |    2 +-
 net/atm/clip.c       |    2 +-
 net/atm/lec.c        |    2 +-
 net/atm/mpc.c        |    2 +-
 net/atm/signaling.c  |    2 +-
 net/dccp/minisocks.c |    2 +-
 net/ipv6/mip6.c      |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff -puN drivers/atm/atmtcp.c~spin_lock_unlocked-cleanup-in-drivers-atm-net drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/drivers/atm/atmtcp.c
@@ -352,7 +352,7 @@ static struct atm_dev atmtcp_control_dev
 	.ops		= &atmtcp_c_dev_ops,
 	.type		= "atmtcp",
 	.number		= 999,
-	.lock		= SPIN_LOCK_UNLOCKED
+	.lock		= __SPIN_LOCK_UNLOCKED(atmtcp_control_dev.lock)
 };
 
 
diff -puN net/atm/clip.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/atm/clip.c
--- a/net/atm/clip.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/atm/clip.c
@@ -702,7 +702,7 @@ static struct atm_dev atmarpd_dev = {
 	.ops =			&atmarpd_dev_ops,
 	.type =			"arpd",
 	.number = 		999,
-	.lock =			SPIN_LOCK_UNLOCKED
+	.lock =			__SPIN_LOCK_UNLOCKED(atmarpd_dev.lock)
 };
 
 
diff -puN net/atm/lec.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/atm/lec.c
--- a/net/atm/lec.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/atm/lec.c
@@ -630,7 +630,7 @@ static struct atm_dev lecatm_dev = {
 	.ops = &lecdev_ops,
 	.type = "lec",
 	.number = 999,		/* dummy device number */
-	.lock = SPIN_LOCK_UNLOCKED
+	.lock = __SPIN_LOCK_UNLOCKED(lecatm_dev.lock)
 };
 
 /*
diff -puN net/atm/mpc.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/atm/mpc.c
--- a/net/atm/mpc.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/atm/mpc.c
@@ -737,7 +737,7 @@ static struct atm_dev mpc_dev = {
 	.ops	= &mpc_ops,
 	.type	= "mpc",
 	.number	= 42,
-	.lock	= SPIN_LOCK_UNLOCKED
+	.lock	= __SPIN_LOCK_UNLOCKED(mpc_dev.lock)
 	/* members not explicitly initialised will be 0 */
 };
 
diff -puN net/atm/signaling.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/atm/signaling.c
--- a/net/atm/signaling.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/atm/signaling.c
@@ -256,7 +256,7 @@ static struct atm_dev sigd_dev = {
 	.ops =		&sigd_dev_ops,
 	.type =		"sig",
 	.number =	999,
-	.lock =		SPIN_LOCK_UNLOCKED
+	.lock =		__SPIN_LOCK_UNLOCKED(sigd_dev.lock)
 };
 
 
diff -puN net/dccp/minisocks.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/dccp/minisocks.c
--- a/net/dccp/minisocks.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/dccp/minisocks.c
@@ -27,7 +27,7 @@
 struct inet_timewait_death_row dccp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
 	.period		= DCCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
-	.death_lock	= SPIN_LOCK_UNLOCKED,
+	.death_lock	= __SPIN_LOCK_UNLOCKED(dccp_death_row.death_lock),
 	.hashinfo	= &dccp_hashinfo,
 	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
 					    (unsigned long)&dccp_death_row),
diff -puN net/ipv6/mip6.c~spin_lock_unlocked-cleanup-in-drivers-atm-net net/ipv6/mip6.c
--- a/net/ipv6/mip6.c~spin_lock_unlocked-cleanup-in-drivers-atm-net
+++ a/net/ipv6/mip6.c
@@ -125,7 +125,7 @@ struct mip6_report_rate_limiter {
 };
 
 static struct mip6_report_rate_limiter mip6_report_rl = {
-	.lock = SPIN_LOCK_UNLOCKED
+	.lock = __SPIN_LOCK_UNLOCKED(mip6_report_rl.lock)
 };
 
 static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
_
