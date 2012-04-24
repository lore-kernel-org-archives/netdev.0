From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH] b44: properly use pr_fmt()
Date: Mon, 23 Apr 2012 19:46:43 -0700
Message-ID: <1335235603-32420-1-git-send-email-mcgrof@do-not-panic.com>
Cc: netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:63469 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab2DXCqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:46:49 -0400
Received: by dadz8 with SMTP id z8so266181dad.10
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>

pr_fmt() is either defined or we redefine it. Typically
drivers define it prior to including printk.h but this
is done under the assumption that no other subsystem
it uses has already defined pr_fmt(). In such cases
pr_fmt() should be undefined and redefined.

Doing this properly shaves down compilation time quite
considerably.

Signed-off-by: Luis R. Rodriguez <mcgrof@do-not-panic.com>
---
 drivers/net/ethernet/broadcom/b44.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 46b8b7d..656f323 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -10,9 +10,11 @@
  * Distribute under GPL.
  */
 
+#undef pr_fmt
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/kernel.h>
+#include <linux/printk.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/types.h>
-- 
1.7.10.rc1.22.gf5241
