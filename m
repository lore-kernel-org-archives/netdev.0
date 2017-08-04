From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: uapi: MAX_ADDR_LEN vs. numeric 32
Date: Sat, 5 Aug 2017 00:33:25 +0300
Message-ID: <20170804213325.GC28459@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@virtuozzo.com>
To: "Dmitry V. Levin" <ldv@altlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([91.232.154.25]:49282 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdHDVwd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 17:52:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First, thanks Dmitry for fixing several uapi compilation problems in
user space. I got a bit demotivated about the slow review progress, e.g.
no feedback what so ever, on some of the patches, but lets try again...

I rebased my tree now and saw

commit 745cb7f8a5de0805cade3de3991b7a95317c7c73
Author: Dmitry V. Levin <ldv@altlinux.org>
Date:   Tue Mar 7 23:50:50 2017 +0300

    uapi: fix linux/packet_diag.h userspace compilation error

which does:

--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -64,7 +64,7 @@ struct packet_diag_mclist {
        __u32   pdmc_count;
        __u16   pdmc_type;
        __u16   pdmc_alen;
-       __u8    pdmc_addr[MAX_ADDR_LEN];
+       __u8    pdmc_addr[32]; /* MAX_ADDR_LEN */
 };
 
 struct packet_diag_ring {

In my tree I had fixed that case with:

--- a/include/uapi/linux/packet_diag.h
+++ b/include/uapi/linux/packet_diag.h
@@ -2,6 +2,7 @@
 #define __PACKET_DIAG_H__
 
 #include <linux/types.h>
+#include <linux/netdevice.h>
 
 struct packet_diag_req {
        __u8    sdiag_family;

since netdevice.h has the definition also in user space

#define MAX_ADDR_LEN    32              /* Largest hardware address length */

I find using MAX_ADDR_LEN better than numeric 32, though I doubt this will
change any time soon. Would you mind if I change packet_diag.h and
if_link.h to use that instead and fix the userspace compilation
problems by including netdevice.h?

Thanks,

-Mikko
