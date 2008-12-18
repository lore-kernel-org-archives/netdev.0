From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH] net: ppp_generic - use DEFINE_IDR for static initialization
Date: Thu, 18 Dec 2008 18:46:36 +0300
Message-ID: <20081218154636.GB12874@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>, NKML <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:65371 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYLRPql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 10:46:41 -0500
Received: by fg-out-1718.google.com with SMTP id 19so200325fgg.17
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 07:46:37 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review.

---
>From 17bbdd601fc1be761876165488879def4649c968 Mon Sep 17 00:00:00 2001
From: Cyrill Gorcunov <gorcunov@openvz.org>
Date: Thu, 18 Dec 2008 18:41:42 +0300
Subject: [PATCH] net: ppp_generic - use DEFINE_IDR for static initialization

We could use DEFINE_IDR for statically allocated idr
that allow us to save a few lines of code.

And spell fix.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: David Miller <davem@davemloft.net>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/ppp_generic.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 293e1c4..b13e600 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -178,7 +178,7 @@ struct channel {
  */
 static DEFINE_MUTEX(all_ppp_mutex);
 static atomic_t ppp_unit_count = ATOMIC_INIT(0);
-static struct idr ppp_units_idr;
+static DEFINE_IDR(ppp_units_idr);
 
 /*
  * all_channels_lock protects all_channels and last_channel_index,
@@ -841,8 +841,6 @@ static int __init ppp_init(void)
 		device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), "ppp");
 	}
 
-	idr_init(&ppp_units_idr);
-
 out:
 	if (err)
 		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
@@ -2426,7 +2424,7 @@ ppp_create_interface(int unit, int *retp)
 		if (unit_find(&ppp_units_idr, unit))
 			goto out2; /* unit already exists */
 		else {
-			/* darn, someone is cheatting us? */
+			/* darn, someone is cheating us? */
 			*retp = -EINVAL;
 			goto out2;
 		}
-- 
1.6.0.4.603.gbc9c0

