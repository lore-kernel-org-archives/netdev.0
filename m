From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/7] rtlwifi: Optimize RT_TRACE macro use of KBUILD_MODNAME for size
Date: Wed,  4 Jan 2012 19:40:45 -0800
Message-ID: <607435af8ce654846413391304e51f39c22c47dd.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60188 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932247Ab2AEDnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 22:43:03 -0500
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving the KBUILD_MODNAME to the format reduces the
overall object size a small amount.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 586904	  55333	 127216	 769453	  bbdad	drivers/net/wireless/rtlwifi/built-in.o.new
 588901	  55333	 127216	 771450	  bc57a	drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/debug.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 74b6780..b024c23 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -168,9 +168,9 @@ do {									\
 do {									\
 	if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) &&	\
 		     ((level) <= rtlpriv->dbg.global_debuglevel))) {	\
-		printk(KERN_DEBUG "%s:%s():<%lx-%x> " fmt,		\
-		       KBUILD_MODNAME, __func__,			\
-		       in_interrupt(), in_atomic(), ##__VA_ARGS__);	\
+		printk(KERN_DEBUG KBUILD_MODNAME ":%s():<%lx-%x> " fmt,	\
+		       __func__, in_interrupt(), in_atomic(),		\
+		       ##__VA_ARGS__);					\
 	}								\
 } while (0)
 
-- 
1.7.8.111.gad25c.dirty
