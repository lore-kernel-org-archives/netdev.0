From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] Net: ath5k, remove sysctls
Date: Wed, 22 Aug 2007 22:54:07 +0200 (CEST)
Message-ID: <782311765865710289@wsc.cz>
References: <2698018635706419125@wsc.cz>
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <2698018635706419125-2EuRcrBQ8V0@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ath5k, remove sysctls

Syscalls were buggy and defunct in later kernels (due to sysctl check).

Signed-off-by: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---
commit 069bfbe93facb3468f579568434d18f1268a487c
tree 87c19ebf2c91d9fb07f1847adcb6098f2235eaaa
parent b01c0e9a02b248c3e2f2923da9728ba2c3961dee
author Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Wed, 22 Aug 2007 22:48:41 +0200
committer Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> Wed, 22 Aug 2007 22:48:41 +0200

 drivers/net/wireless/ath5k_base.c |   23 ++++++++---------------
 1 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath5k_base.c b/drivers/net/wireless/ath5k_base.c
index 2ce82ed..7f938c4 100644
--- a/drivers/net/wireless/ath5k_base.c
+++ b/drivers/net/wireless/ath5k_base.c
@@ -2440,21 +2440,13 @@ static struct pci_driver ath_pci_drv_id = {
 	.resume		= ath_pci_resume,
 };
 
-/*
- * Static (i.e. global) sysctls.  Note that the hal sysctls
- * are located under ours by sharing the setting for DEV_ATH.
- */
-enum {
-	DEV_ATH		= 9,			/* XXX known by hal */
-};
-
 static int mincalibrate = 1;
 static int maxcalibrate = INT_MAX / 1000;
 #define	CTL_AUTO	-2	/* cannot be CTL_ANY or CTL_NONE */
 
 static ctl_table ath_static_sysctls[] = {
 #if AR_DEBUG
-	{ .ctl_name	= CTL_AUTO,
+	{
 	  .procname	= "debug",
 	  .mode		= 0644,
 	  .data		= &ath_debug,
@@ -2462,28 +2454,28 @@ static ctl_table ath_static_sysctls[] = {
 	  .proc_handler	= proc_dointvec
 	},
 #endif
-	{ .ctl_name	= CTL_AUTO,
+	{
 	  .procname	= "countrycode",
 	  .mode		= 0444,
 	  .data		= &countrycode,
 	  .maxlen	= sizeof(countrycode),
 	  .proc_handler	= proc_dointvec
 	},
-	{ .ctl_name	= CTL_AUTO,
+	{
 	  .procname	= "outdoor",
 	  .mode		= 0444,
 	  .data		= &outdoor,
 	  .maxlen	= sizeof(outdoor),
 	  .proc_handler	= proc_dointvec
 	},
-	{ .ctl_name	= CTL_AUTO,
+	{
 	  .procname	= "xchanmode",
 	  .mode		= 0444,
 	  .data		= &xchanmode,
 	  .maxlen	= sizeof(xchanmode),
 	  .proc_handler	= proc_dointvec
 	},
-	{ .ctl_name	= CTL_AUTO,
+	{
 	  .procname	= "calibrate",
 	  .mode		= 0644,
 	  .data		= &ath_calinterval,
@@ -2495,14 +2487,15 @@ static ctl_table ath_static_sysctls[] = {
 	{ 0 }
 };
 static ctl_table ath_ath_table[] = {
-	{ .ctl_name	= DEV_ATH,
+	{
 	  .procname	= "ath",
 	  .mode		= 0555,
 	  .child	= ath_static_sysctls
 	}, { 0 }
 };
 static ctl_table ath_root_table[] = {
-	{ .ctl_name	= CTL_DEV,
+	{
+	  .ctl_name	= CTL_DEV,
 	  .procname	= "dev",
 	  .mode		= 0555,
 	  .child	= ath_ath_table
