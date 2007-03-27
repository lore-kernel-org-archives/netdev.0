From: akpm@linux-foundation.org
Subject: [patch 3/7] Delete unused header file linux/if_wanpipe_common.h
Date: Mon, 26 Mar 2007 21:49:59 -0800
Message-ID: <200703270549.l2R5nx34008375@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@mindspring.com, khc@pm.waw.pl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40340 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934049AbXC0FuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:50:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@mindspring.com>

Delete the unreferenced header file include/linux/if_wanpipe_common.h,
as well as the reference to it in the Doc file.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/networking/wan-router.txt |    1 
 include/linux/if_wanpipe_common.h       |   58 ----------------------
 2 files changed, 59 deletions(-)

diff -puN Documentation/networking/wan-router.txt~delete-unused-header-file-linux-if_wanpipe_commonh Documentation/networking/wan-router.txt
--- a/Documentation/networking/wan-router.txt~delete-unused-header-file-linux-if_wanpipe_commonh
+++ a/Documentation/networking/wan-router.txt
@@ -250,7 +250,6 @@ PRODUCT COMPONENTS AND RELATED FILES
 	sdladrv.h	SDLA support module API definitions
 	sdlasfm.h	SDLA firmware module definitions
 	if_wanpipe.h	WANPIPE Socket definitions
-	if_wanpipe_common.h	WANPIPE Socket/Driver common definitions.
 	sdlapci.h	WANPIPE PCI definitions
 	
 
diff -puN include/linux/if_wanpipe_common.h~delete-unused-header-file-linux-if_wanpipe_commonh /dev/null
--- a/include/linux/if_wanpipe_common.h
+++ /dev/null
@@ -1,58 +0,0 @@
-/*****************************************************************************
-* if_wanipe_common.h   Sangoma Driver/Socket common area definitions.
-*
-* Author:       Nenad Corbic <ncorbic@sangoma.com>
-*
-* Copyright:    (c) 2000 Sangoma Technologies Inc.
-*
-*               This program is free software; you can redistribute it and/or
-*               modify it under the terms of the GNU General Public License
-*               as published by the Free Software Foundation; either version
-*               2 of the License, or (at your option) any later version.
-* ============================================================================
-* Jan 13, 2000  Nenad Corbic      Initial version
-*****************************************************************************/
-
-
-#ifndef _WANPIPE_SOCK_DRIVER_COMMON_H
-#define _WANPIPE_SOCK_DRIVER_COMMON_H
-
-typedef struct {
-	struct net_device *slave;
-	atomic_t packet_sent;
-	atomic_t receive_block;
-	atomic_t command;
-	atomic_t disconnect;
-	atomic_t driver_busy;
-	long common_critical;
-	struct timer_list *tx_timer;
-	struct sock *sk;		/* Wanpipe Sock bind's here */ 
-	int (*func)(struct sk_buff *skb, struct net_device *dev, 
-		    struct sock *sk);
-
-	struct work_struct wanpipe_work;    /* deferred keventd work */
-	unsigned char rw_bind;			  /* Sock bind state */
-	unsigned char usedby;
-	unsigned char state;
-	unsigned char svc;
-	unsigned short lcn;
-	void *mbox;
-} wanpipe_common_t;
-
-
-enum {
-	WANSOCK_UNCONFIGURED,	/* link/channel is not configured */
-	WANSOCK_DISCONNECTED,	/* link/channel is disconnected */
-	WANSOCK_CONNECTING,		/* connection is in progress */
-	WANSOCK_CONNECTED,		/* link/channel is operational */
-	WANSOCK_LIMIT,		/* for verification only */
-	WANSOCK_DUALPORT,		/* for Dual Port cards */
-	WANSOCK_DISCONNECTING,
-	WANSOCK_BINDED,
-	WANSOCK_BIND_LISTEN,
-	WANSOCK_LISTEN
-};
-
-#endif
-
-
_
