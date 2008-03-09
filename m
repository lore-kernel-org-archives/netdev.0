From: Jon Schindler <jkschind@gmail.com>
Subject: Re: [patch 16/17] drivers/net/8390.c: replace init_module&cleanup_module
 with module_init&module_exit
Date: Sun, 09 Mar 2008 01:00:21 -0600
Message-ID: <47D38B05.6000708@gmail.com>
References: <200803042319.m24NJXjS002733@imap1.linux-foundation.org> <47D1D70A.2070003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:22973 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbYCIHAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 03:00:11 -0400
Received: by py-out-1112.google.com with SMTP id u52so1975518pyb.10
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 23:00:09 -0800 (PST)
In-Reply-To: <47D1D70A.2070003@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replaced init_module and cleanup_module with static functions and module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
---
diff --git a/drivers/net/8390.c b/drivers/net/8390.c
index a828076..0ed41a3 100644
--- a/drivers/net/8390.c
+++ b/drivers/net/8390.c
@@ -48,14 +48,16 @@ EXPORT_SYMBOL(__alloc_ei_netdev);
 
 #if defined(MODULE)
 
-int init_module(void)
+static int __init ns8390_module_init(void)
 {
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit ns8390_module_exit(void)
 {
 }
 
+module_init(ns8390_module_init);
+module_exit(ns8390_module_exit);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
