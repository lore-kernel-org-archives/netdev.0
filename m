From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch]
Date: Sat, 2 Jul 2005 23:48:36 +0200
Message-ID: <20050702214836.GD5346@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261297AbVGBVt1@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following kconfig warning:
  net/ipv4/Kconfig:92:warning: defaults for choice values not supported

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

I've Cc'ed Roman because I might have missed a more elegant solution.

--- linux-2.6.13-rc1-mm1-full/net/ipv4/Kconfig.old	2005-07-02 20:07:25.000000000 +0200
+++ linux-2.6.13-rc1-mm1-full/net/ipv4/Kconfig	2005-07-02 20:13:05.000000000 +0200
@@ -58,8 +58,9 @@
 	depends on IP_ADVANCED_ROUTER
 	default IP_FIB_HASH
 
-config IP_FIB_HASH
+config ASK_IP_FIB_HASH
 	bool "FIB_HASH"
+	select IP_FIB_HASH
 	---help---
 	Current FIB is very proven and good enough for most users.
 
@@ -84,12 +85,9 @@
        
 endchoice
 
-# If the user does not enable advanced routing, he gets the safe
-# default of the fib-hash algorithm.
 config IP_FIB_HASH
 	bool
-	depends on !IP_ADVANCED_ROUTER
-	default y
+	default y if !IP_ADVANCED_ROUTER
 
 config IP_MULTIPLE_TABLES
 	bool "IP: policy routing"
