From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V3.18] rtlwifi: rtl8192ee: Prevent log spamming for
 switch statements
Date: Sat, 11 Oct 2014 11:14:46 -0700
Message-ID: <1413051286.22149.2.camel@joe-AO725>
References: <1413050393-6257-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	troy_tan@realsil.com.cn, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0036.hostedemail.com ([216.40.44.36]:46240 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752502AbaJKSOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 14:14:49 -0400
In-Reply-To: <1413050393-6257-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-11 at 12:59 -0500, Larry Finger wrote:
> The driver logs a message when the default branch of switch statements are
> taken. Such information is useful when debugging, but these log items should
> not be seen for standard usage.

Hey Larry.

At some point, it'd be good to make RT_TRACE use
the generic dynamic_debug facility.

Something like the below, but I believe there are
some issues with include ordering and #define DEBUG
when dynamic_debug is not #defined.

---

 drivers/net/wireless/rtlwifi/debug.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index fc794b3..fbc8185 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -178,17 +178,14 @@ do {									\
 do {									\
 	if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) &&	\
 		     ((level) <= rtlpriv->dbg.global_debuglevel))) {	\
-		printk(KERN_DEBUG KBUILD_MODNAME ":%s():<%lx-%x> " fmt,	\
-		       __func__, in_interrupt(), in_atomic(),		\
-		       ##__VA_ARGS__);					\
+		pr_debug(fmt, ##__VA_ARGS__);				\
 	}								\
 } while (0)
 
 #define RTPRINT(rtlpriv, dbgtype, dbgflag, fmt, ...)			\
 do {									\
 	if (unlikely(rtlpriv->dbg.dbgp_type[dbgtype] & dbgflag)) {	\
-		printk(KERN_DEBUG KBUILD_MODNAME ": " fmt,		\
-		       ##__VA_ARGS__);					\
+		pr_debug(fmt, ##__VA_ARGS__);				\
 	}								\
 } while (0)
 
