From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] arlan: fix section mismatch warnings
Date: Thu, 25 May 2006 11:10:08 -0700
Message-ID: <20060525111008.d9f85a14.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:10635 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1030305AbWEYSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 14:07:39 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 25 May 2006 11:07:38 -0700
To: ismail@pardus.org.tr, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix section mismatch warnings:
WARNING: drivers/net/wireless/arlan.o - Section mismatch: reference to
.init.text:arlan_probe from .text between 'init_module' (at offset
0x3526) and 'cleanup_module'
WARNING: drivers/net/wireless/arlan.o - Section mismatch: reference to
.init.text:init_arlan_proc from .text between 'init_module' (at offset
0x3539) and 'cleanup_module'
WARNING: drivers/net/wireless/arlan.o - Section mismatch: reference to
.exit.text:cleanup_arlan_proc from .text between 'cleanup_module' (at
offset 0x356c) and 'arlan_diagnostic_info_string'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/wireless/arlan-main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2617-rc5.orig/drivers/net/wireless/arlan-main.c
+++ linux-2617-rc5/drivers/net/wireless/arlan-main.c
@@ -1838,7 +1838,7 @@ struct net_device * __init arlan_probe(i
 }
 
 #ifdef  MODULE
-int init_module(void)
+int __init init_module(void)
 {
 	int i = 0;
 
@@ -1860,7 +1860,7 @@ int init_module(void)
 }
 
 
-void cleanup_module(void)
+void __exit cleanup_module(void)
 {
 	int i = 0;
 	struct net_device *dev;


---
