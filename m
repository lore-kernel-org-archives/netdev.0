From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Fri, 5 Nov 2004 03:22:22 -0500
Message-ID: <20041105082222.GA25906@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 include/net/iw_handler.h |    8 ++++----
 net/core/wireless.c      |    9 +++++++--
 2 files changed, 11 insertions(+), 6 deletions(-)

through these ChangeSets:

<jt@bougret.hpl.hp.com> (04/11/05 1.2465)
   [PATCH] Wireless Extension dropped patchlet
   
   	This tiny bit of the last WE-17 patch was lost between me and
   you. I initially decided to wait to resubmit, but Chris Wedgwood
   reported that the MadWifi driver needs it. Sorry for not having pushed
   harder.
   	I recreated this patch, and tested with 2.6.10-rc1, and Chris
   tested it with MadWifi. Would you mind pushing that up to Linus ?
   
   Changelog :
   	o remove unneeded const
   	o spelling + comments
   
   Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

diff -Nru a/include/net/iw_handler.h b/include/net/iw_handler.h
--- a/include/net/iw_handler.h	2004-11-05 03:21:48 -05:00
+++ b/include/net/iw_handler.h	2004-11-05 03:21:48 -05:00
@@ -314,10 +314,10 @@
 {
 	/* Number of handlers defined (more precisely, index of the
 	 * last defined handler + 1) */
-	const __u16		num_standard;
-	const __u16		num_private;
+	__u16			num_standard;
+	__u16			num_private;
 	/* Number of private arg description */
-	const __u16		num_private_args;
+	__u16			num_private_args;
 
 	/* Array of handlers for standard ioctls
 	 * We will call dev->wireless_handlers->standard[ioctl - SIOCSIWNAME]
@@ -335,7 +335,7 @@
 	const struct iw_priv_args *	private_args;
 
 	/* This field will be *removed* in the next version of WE */
-	const long		spy_offset;	/* DO NOT USE */
+	long			spy_offset;	/* DO NOT USE */
 
 	/* New location of get_wireless_stats, to de-bloat struct net_device.
 	 * The old pointer in struct net_device will be gradually phased
diff -Nru a/net/core/wireless.c b/net/core/wireless.c
--- a/net/core/wireless.c	2004-11-05 03:21:48 -05:00
+++ b/net/core/wireless.c	2004-11-05 03:21:48 -05:00
@@ -52,7 +52,8 @@
  * v6 - 18.06.04 - Jean II
  *	o Change get_spydata() method for added safety
  *	o Remove spy #ifdef, they are always on -> cleaner code
- *	o Allow any size GET request is user specifies length > max
+ *	o Allow any size GET request if user specifies length > max
+ *		and if request has IW_DESCR_FLAG_NOMAX flag or is SIOCGIWPRIV
  *	o Start migrating get_wireless_stats to struct iw_handler_def
  *	o Add wmb() in iw_handler_set_spy() for non-coherent archs/cpus
  * Based on patch from Pavel Roskin <proski@gnu.org> :
@@ -690,6 +691,10 @@
 				 * we can support any size GET requests.
 				 * There is still a limit : -ENOMEM. */
 				extra_size = user_length * descr->token_size;
+				/* Note : user_length is originally a __u16,
+				 * and token_size is controlled by us,
+				 * so extra_size won't get negative and
+				 * won't overflow... */
 			}
 		}
 
@@ -1227,7 +1232,7 @@
 
 	/* We want to operate without locking, because wireless_spy_update()
 	 * most likely will happen in the interrupt handler, and therefore
-	 * have it own locking constraints and needs performance.
+	 * have its own locking constraints and needs performance.
 	 * The rtnl_lock() make sure we don't race with the other iw_handlers.
 	 * This make sure wireless_spy_update() "see" that the spy list
 	 * is temporarily disabled. */
