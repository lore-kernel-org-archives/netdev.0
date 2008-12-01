From: akpm@linux-foundation.org
Subject: [patch 4/5] drivers/isdn/mISDN: use ARRAY_SIZE
Date: Mon, 01 Dec 2008 14:24:24 -0800
Message-ID: <200812012224.mB1MOO74014990@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36395 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752667AbYLAWZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:25:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

ARRAY_SIZE is more concise to use when the size of an array is divided by
the size of its type or the size of its first element.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@i@
@@

#include <linux/kernel.h>

@depends on i using "paren.iso"@
type T;
T[] E;
@@

- (sizeof(E)/sizeof(T))
+ ARRAY_SIZE(E)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/dsp_hwec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/mISDN/dsp_hwec.c~drivers-isdn-misdn-use-array_size drivers/isdn/mISDN/dsp_hwec.c
--- a/drivers/isdn/mISDN/dsp_hwec.c~drivers-isdn-misdn-use-array_size
+++ a/drivers/isdn/mISDN/dsp_hwec.c
@@ -43,7 +43,7 @@ static struct mISDN_dsp_element dsp_hwec
 	.free = NULL,
 	.process_tx = NULL,
 	.process_rx = NULL,
-	.num_args = sizeof(args) / sizeof(struct mISDN_dsp_element_arg),
+	.num_args = ARRAY_SIZE(args),
 	.args = args,
 };
 struct mISDN_dsp_element *dsp_hwec = &dsp_hwec_p;
_
