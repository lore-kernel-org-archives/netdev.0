From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] llc: make lock static
Date: Fri, 3 Jan 2014 09:19:51 -0800
Message-ID: <20140103091951.06153029@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37317 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbaACRT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 12:19:58 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so15960753pab.21
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 09:19:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The llc_sap_list_lock does not need to be global, only acquired
in core.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/llc.h	2013-12-30 21:34:18.438981005 -0800
+++ b/include/net/llc.h	2013-12-30 21:34:51.602557247 -0800
@@ -93,7 +93,6 @@ struct hlist_nulls_head *llc_sk_laddr_ha
 #define LLC_DEST_CONN            2      /* Type 2 goes here */
 
 extern struct list_head llc_sap_list;
-extern spinlock_t llc_sap_list_lock;
 
 int llc_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	    struct net_device *orig_dev);
--- a/net/llc/llc_core.c	2013-12-30 21:34:18.438981005 -0800
+++ b/net/llc/llc_core.c	2013-12-30 21:34:51.602557247 -0800
@@ -23,7 +23,7 @@
 #include <net/llc.h>
 
 LIST_HEAD(llc_sap_list);
-DEFINE_SPINLOCK(llc_sap_list_lock);
+static DEFINE_SPINLOCK(llc_sap_list_lock);
 
 /**
  *	llc_sap_alloc - allocates and initializes sap.
@@ -159,7 +159,6 @@ module_init(llc_init);
 module_exit(llc_exit);
 
 EXPORT_SYMBOL(llc_sap_list);
-EXPORT_SYMBOL(llc_sap_list_lock);
 EXPORT_SYMBOL(llc_sap_find);
 EXPORT_SYMBOL(llc_sap_open);
 EXPORT_SYMBOL(llc_sap_close);
