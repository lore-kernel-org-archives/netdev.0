From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/2] gigaset: get rid of info() and warn() macros
Date: Sat, 29 Nov 2008 23:41:07 +0100 (CET)
Message-ID: <ba0787515baca3b67eca4bc526a3a7b2db70bbb9.1227876791.git.tilman@imap.cc>
References: <1227876791.git.tilman@imap.cc>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755536AbYK2Wlp@vger.kernel.org>
In-Reply-To: <1227876791.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Join the move away from the obsolete info() macro, opencoding the
remaining uses. While we're at it, also get rid of the warn() macro
by promoting the three remaining uses to err().

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |    3 +--
 drivers/isdn/gigaset/common.c      |    5 ++---
 drivers/isdn/gigaset/gigaset.h     |    6 ------
 drivers/isdn/gigaset/interface.c   |    4 ++--
 drivers/isdn/gigaset/ser-gigaset.c |    3 +--
 drivers/isdn/gigaset/usb-gigaset.c |    3 +--
 6 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 3f11910..3eca9c8 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2507,8 +2507,7 @@ static int __init bas_gigaset_init(void)
 		goto error;
 	}
 
-	info(DRIVER_AUTHOR);
-	info(DRIVER_DESC);
+	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
 	return 0;
 
 error:
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 9d3ce77..1664e31 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -580,7 +580,7 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	} else if ((bcs->skb = dev_alloc_skb(SBUFSIZE + HW_HDR_LEN)) != NULL)
 		skb_reserve(bcs->skb, HW_HDR_LEN);
 	else {
-		warn("could not allocate skb");
+		err("could not allocate skb");
 		bcs->inputstate |= INS_skip_frame;
 	}
 
@@ -1120,8 +1120,7 @@ static int __init gigaset_init_module(void)
 	if (gigaset_debuglevel == 1)
 		gigaset_debuglevel = DEBUG_DEFAULT;
 
-	info(DRIVER_AUTHOR);
-	info(DRIVER_DESC);
+	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
 	return 0;
 }
 
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 0037529..901ff43 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -104,15 +104,9 @@ enum debuglevel {
  * removed rather than fixed anyway.
  */
 #undef err
-#undef info
-#undef warn
 
 #define err(format, arg...) printk(KERN_ERR KBUILD_MODNAME ": " \
 	format "\n" , ## arg)
-#define info(format, arg...) printk(KERN_INFO KBUILD_MODNAME ": " \
-	format "\n" , ## arg)
-#define warn(format, arg...) printk(KERN_WARNING KBUILD_MODNAME ": " \
-	format "\n" , ## arg)
 
 #ifdef CONFIG_GIGASET_DEBUG
 
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 521951a..956381c 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -701,7 +701,7 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 
 	ret = tty_register_driver(tty);
 	if (ret < 0) {
-		warn("failed to register tty driver (error %d)", ret);
+		err("failed to register tty driver (error %d)", ret);
 		goto error;
 	}
 	gig_dbg(DEBUG_IF, "tty driver initialized");
@@ -709,7 +709,7 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 	return;
 
 enomem:
-	warn("could not allocate tty structures");
+	err("could not allocate tty structures");
 error:
 	if (drv->tty)
 		put_tty_driver(drv->tty);
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 0b8c8f2..b306a2f 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -513,8 +513,7 @@ gigaset_tty_open(struct tty_struct *tty)
 
 	gig_dbg(DEBUG_INIT, "Starting HLL for Gigaset M101");
 
-	info(DRIVER_AUTHOR);
-	info(DRIVER_DESC);
+	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
 
 	if (!driver) {
 		err("%s: no driver structure", __func__);
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 4661830..e847c6e 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -941,8 +941,7 @@ static int __init usb_gigaset_init(void)
 		goto error;
 	}
 
-	info(DRIVER_AUTHOR);
-	info(DRIVER_DESC);
+	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_DESC "\n");
 	return 0;
 
 error:
-- 
1.6.0.1.100.gcb138
