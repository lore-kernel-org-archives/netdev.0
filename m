From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix IP_FIB_HASH kconfig warning
Date: Sat, 9 Jul 2005 05:07:30 +0200
Message-ID: <20050709030730.GC28243@stusta.de>
References: <20050703222002.GQ5346@stusta.de> <Pine.LNX.4.61.0507042025180.3728@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261356AbVGIDLW@vger.kernel.org>
To: Roman Zippel <zippel@linux-m68k.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0507042025180.3728@scrub.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 04, 2005 at 08:27:56PM +0200, Roman Zippel wrote:

>...
> config IP_FIB_HASH  
> 	def_bool ASK_IP_FIB_HASH || !IP_ADVANCED_ROUTER

An updated patch is below.

> bye, Roman

cu
Adrian


<--  snip  -->


This patch fixes the following kconfig warning:
  net/ipv4/Kconfig:92:warning: defaults for choice values not supported

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc2-mm1-modular/net/ipv4/Kconfig.old	2005-07-08 23:55:31.000000000 +0200
+++ linux-2.6.13-rc2-mm1-modular/net/ipv4/Kconfig	2005-07-08 23:56:23.000000000 +0200
@@ -56,9 +56,9 @@
 choice 
 	prompt "Choose IP: FIB lookup algorithm (choose FIB_HASH if unsure)"
 	depends on IP_ADVANCED_ROUTER
-	default IP_FIB_HASH
+	default ASK_IP_FIB_HASH
 
-config IP_FIB_HASH
+config ASK_IP_FIB_HASH
 	bool "FIB_HASH"
 	---help---
 	Current FIB is very proven and good enough for most users.
@@ -84,12 +84,8 @@
        
 endchoice
 
-# If the user does not enable advanced routing, he gets the safe
-# default of the fib-hash algorithm.
 config IP_FIB_HASH
-	bool
-	depends on !IP_ADVANCED_ROUTER
-	default y
+	def_bool ASK_IP_FIB_HASH || !IP_ADVANCED_ROUTER
 
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
