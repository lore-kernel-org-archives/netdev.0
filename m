From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -next] connector: make cn_proc explicitly non-modular
Date: Mon, 4 Jul 2016 17:50:58 -0400
Message-ID: <20160704215058.13593-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Evgeniy Polyakov <zbr@ioremap.net>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57183 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932661AbcGDVvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:51:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig controlling build of this code is currently:

drivers/connector/Kconfig:config PROC_EVENTS
drivers/connector/Kconfig:      bool "Report process events to userspace"

...meaning that it currently is not being built as a module by anyone.
Lets remove the two modular references, so that when reading the driver
there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/connector/cn_proc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index b02f9c606e0b..a782ce87715c 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -22,7 +22,6 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/ktime.h>
 #include <linux/init.h>
@@ -390,5 +389,4 @@ static int __init cn_proc_init(void)
 	}
 	return 0;
 }
-
-module_init(cn_proc_init);
+device_initcall(cn_proc_init);
-- 
2.8.4
