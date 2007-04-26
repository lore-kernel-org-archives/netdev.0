From: akpm@linux-foundation.org
Subject: [patch 02/11] vioc-warning-fix
Date: Thu, 26 Apr 2007 00:23:15 -0700
Message-ID: <200704260723.l3Q7NF6G023823@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	driver-support@fabric7.com, schidambaram@fabric7.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:58612 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933133AbXDZHXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:23:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Fix this, on i386:

drivers/net/vioc/vioc_transmit.c: In function 'vioc_tx_interrupt':
drivers/net/vioc/vioc_transmit.c:387: warning: cast from pointer to integer of different size

I dunno what the driver is trying to do here, but it looks unpleasant.

Cc: Sriram Chidambaram <schidambaram@fabric7.com>
Cc: Fabric7 Driver-Support <driver-support@fabric7.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/vioc/vioc_vnic.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/net/vioc/vioc_vnic.h~vioc-warning-fix drivers/net/vioc/vioc_vnic.h
--- a/drivers/net/vioc/vioc_vnic.h~vioc-warning-fix
+++ a/drivers/net/vioc/vioc_vnic.h
@@ -103,11 +103,11 @@
        )
 
 #define VIOC_IRQ_PARAM_VIOC_ID(param)  \
-       (int) (((u64) param >> 28) & 0xf)
+       (int) (((long) param >> 28) & 0xf)
 #define VIOC_IRQ_PARAM_INTR_ID(param)  \
-       (int) ((u64) param & 0xffff)
+       (int) ((long) param & 0xffff)
 #define VIOC_IRQ_PARAM_PARAM_ID(param) \
-       (int) (((u64) param >> 16) & 0xff)
+       (int) (((long) param >> 16) & 0xff)
 
 #define VIOC_IRQ_PARAM_SET(vioc, intr, param) \
                ((((u64) vioc & 0xf) << 28) | \
_
