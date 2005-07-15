From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] fix IP_FIB_HASH kconfig warning
Date: Fri, 15 Jul 2005 23:35:08 +0200
Message-ID: <20050715213508.GH18059@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Zippel <zippel@linux-m68k.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261234AbVGOVgy@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following kconfig warning:
  net/ipv4/Kconfig:92:warning: defaults for choice values not supported

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 9 Jul 2005

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
