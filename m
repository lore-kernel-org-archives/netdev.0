From: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Subject: [2.6 patch] net/irda/: possible cleanups
Date: Tue, 9 Aug 2005 17:49:57 +0200
Message-ID: <20050809154957.GY4006@stusta.de>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Content-Disposition: inline
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

This patch contains the following possible cleanups:
- make the following needlessly global function static:
  - irnet/irnet_ppp.c: irnet_init
- remove the following unneeded EXPORT_SYMBOL's:
  - irlmp.c: sysctl_discovery_timeout
  - irlmp.c: irlmp_reasons
  - irlmp.c: irlmp_dup
  - irqueue.c: hashbin_find_next

Please review which of these changes do make sense and which conflict 
with pending patches.

Signed-off-by: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>

---

This patch was already sent on:
- 9 Jul 2005
- 30 May 2005
- 7 May 2005

 net/irda/irlmp.c           |    3 ---
 net/irda/irnet/irnet.h     |    3 ---
 net/irda/irnet/irnet_ppp.c |    2 +-
 net/irda/irqueue.c         |    1 -
 4 files changed, 1 insertion(+), 8 deletions(-)

--- linux-2.6.12-rc3-mm3-full/net/irda/irnet/irnet.h.old	2005-05-05 22:38:59.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/irda/irnet/irnet.h	2005-05-05 22:39:12.000000000 +0200
@@ -517,9 +517,6 @@
 	irda_irnet_init(void);		/* Initialise IrDA part of IrNET */
 extern void
 	irda_irnet_cleanup(void);	/* Teardown IrDA part of IrNET */
-/* ---------------------------- MODULE ---------------------------- */
-extern int
-	irnet_init(void);		/* Initialise IrNET module */
 
 /**************************** VARIABLES ****************************/
 
--- linux-2.6.12-rc3-mm3-full/net/irda/irnet/irnet_ppp.c.old	2005-05-05 22:39:21.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/irda/irnet/irnet_ppp.c	2005-05-05 22:39:29.000000000 +0200
@@ -1107,7 +1107,7 @@
 /*
  * Module main entry point
  */
-int __init
+static int __init
 irnet_init(void)
 {
   int err;
--- linux-2.6.12-rc3-mm3-full/net/irda/irlmp.c.old	2005-05-05 22:46:47.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/irda/irlmp.c	2005-05-05 22:50:52.000000000 +0200
@@ -53,7 +53,6 @@
 /* These can be altered by the sysctl interface */
 int  sysctl_discovery         = 0;
 int  sysctl_discovery_timeout = 3; /* 3 seconds by default */
-EXPORT_SYMBOL(sysctl_discovery_timeout);
 int  sysctl_discovery_slots   = 6; /* 6 slots by default */
 int  sysctl_lap_keepalive_time = LM_IDLE_TIMEOUT * 1000 / HZ;
 char sysctl_devname[65];
@@ -67,7 +66,6 @@
 	"LM_INIT_DISCONNECT",
 	"ERROR, NOT USED",
 };
-EXPORT_SYMBOL(irlmp_reasons);
 
 /*
  * Function irlmp_init (void)
@@ -675,7 +673,6 @@
 
 	return new;
 }
-EXPORT_SYMBOL(irlmp_dup);
 
 /*
  * Function irlmp_disconnect_request (handle, userdata)
--- linux-2.6.12-rc3-mm3-full/net/irda/irqueue.c.old	2005-05-05 22:48:55.000000000 +0200
+++ linux-2.6.12-rc3-mm3-full/net/irda/irqueue.c	2005-05-05 22:49:03.000000000 +0200
@@ -822,7 +822,6 @@
 
 	return entry;
 }
-EXPORT_SYMBOL(hashbin_find_next);
 
 /*
  * Function hashbin_get_first (hashbin)



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
