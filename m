From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Subject: [KJ][PATCH]SPIN_LOCK_UNLOCKED cleanup in drivers/atm, net
Date: Thu, 19 Apr 2007 17:32:19 +0530
Message-ID: <20070419120219.GA12373@arun.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrw Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, chas@cmf.nrl.navy.mil,
	davem@davemloft.net, jgarzik@pobox.com
To: Kernel Janitors <kernel-janitors@lists.osdl.org>,
	linux-atm-general@lists.sourceforge.net,
	NET-DEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:36819 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993244AbXDSL74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 07:59:56 -0400
Received: by ug-out-1314.google.com with SMTP id 44so657334uga
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2007 04:59:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SPIN_LOCK_UNLOCKED cleanup,use __SPIN_LOCK_UNLOCKED instead

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>

---

 drivers/atm/atmtcp.c |    2 +-
 net/atm/clip.c       |    2 +-
 net/atm/lec.c        |    2 +-
 net/atm/mpc.c        |    2 +-
 net/atm/signaling.c  |    2 +-
 net/dccp/minisocks.c |    2 +-
 net/ipv6/mip6.c      |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)


diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index fc518d8..3fde97b 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -352,7 +352,7 @@ static struct atm_dev atmtcp_control_dev = {
 	.ops		= &atmtcp_c_dev_ops,
 	.type		= "atmtcp",
 	.number		= 999,
-	.lock		= SPIN_LOCK_UNLOCKED
+	.lock		= __SPIN_LOCK_UNLOCKED(atmtcp_control_dev.lock)
 };
 
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8c38258..d41137d 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -702,7 +702,7 @@ static struct atm_dev atmarpd_dev = {
 	.ops =			&atmarpd_dev_ops,
 	.type =			"arpd",
 	.number = 		999,
-	.lock =			SPIN_LOCK_UNLOCKED
+	.lock =			__SPIN_LOCK_UNLOCKED(atmarpd_dev.lock)
 };
 
 
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 3d804d6..7747586 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -630,7 +630,7 @@ static struct atm_dev lecatm_dev = {
 	.ops = &lecdev_ops,
 	.type = "lec",
 	.number = 999,		/* dummy device number */
-	.lock = SPIN_LOCK_UNLOCKED
+	.lock = __SPIN_LOCK_UNLOCKED(lecatm_dev.lock)
 };
 
 /*
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index cb3c004..2f0df1f 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -734,7 +734,7 @@ static struct atm_dev mpc_dev = {
 	.ops	= &mpc_ops,
 	.type	= "mpc",
 	.number	= 42,
-	.lock	= SPIN_LOCK_UNLOCKED
+	.lock	= __SPIN_LOCK_UNLOCKED(mpc_dev.lock)
 	/* members not explicitly initialised will be 0 */
 };
 
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 31d98b5..d14baaf 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -256,7 +256,7 @@ static struct atm_dev sigd_dev = {
 	.ops =		&sigd_dev_ops,
 	.type =		"sig",
 	.number =	999,
-	.lock =		SPIN_LOCK_UNLOCKED
+	.lock =		__SPIN_LOCK_UNLOCKED(sigd_dev.lock)
 };
 
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 6d235b3..e18e249 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -27,7 +27,7 @@
 struct inet_timewait_death_row dccp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
 	.period		= DCCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
-	.death_lock	= SPIN_LOCK_UNLOCKED,
+	.death_lock	= __SPIN_LOCK_UNLOCKED(dccp_death_row.death_lock),
 	.hashinfo	= &dccp_hashinfo,
 	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
 					    (unsigned long)&dccp_death_row),
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 0afcabd..7aac558 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -122,7 +122,7 @@ struct mip6_report_rate_limiter {
 };
 
 static struct mip6_report_rate_limiter mip6_report_rl = {
-	.lock = SPIN_LOCK_UNLOCKED
+	.lock = __SPIN_LOCK_UNLOCKED(mip6_report_rl.lock)
 };
 
 static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)

-- 
Milind Arun Choudhary
