From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rfkill: Move rfkill_switch_all out of global header
Date: Fri, 28 Sep 2007 00:07:41 +0200
Message-ID: <200709280007.41676.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:58222 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982AbXI0Vx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 17:53:29 -0400
Received: by mu-out-0910.google.com with SMTP id i10so4498481mue
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 14:53:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rfkill_switch_all shouldn't be called by drivers directly,
instead they should send a signal over the input device.

To prevent confusion for driver developers, move the
function into a rfkill private header.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index f9a50da..67096b5 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -2,7 +2,7 @@
 #define __RFKILL_H
 
 /*
- * Copyright (C) 2006 Ivo van Doorn
+ * Copyright (C) 2006 - 2007 Ivo van Doorn
  * Copyright (C) 2007 Dmitry Torokhov
  *
  * This program is free software; you can redistribute it and/or modify
@@ -84,6 +84,4 @@ void rfkill_free(struct rfkill *rfkill);
 int rfkill_register(struct rfkill *rfkill);
 void rfkill_unregister(struct rfkill *rfkill);
 
-void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state);
-
 #endif /* RFKILL_H */
diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index 8e4516a..eaabf08 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -17,6 +17,8 @@
 #include <linux/init.h>
 #include <linux/rfkill.h>
 
+#include "rfkill-input.h"
+
 MODULE_AUTHOR("Dmitry Torokhov <dtor@mail.ru>");
 MODULE_DESCRIPTION("Input layer to RF switch connector");
 MODULE_LICENSE("GPL");
diff --git a/net/rfkill/rfkill-input.h b/net/rfkill/rfkill-input.h
new file mode 100644
index 0000000..4dae500
--- /dev/null
+++ b/net/rfkill/rfkill-input.h
@@ -0,0 +1,16 @@
+/*
+ * Copyright (C) 2007 Ivo van Doorn
+ */
+
+/*
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation.
+ */
+
+#ifndef __RFKILL_INPUT_H
+#define __RFKILL_INPUT_H
+
+void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state);
+
+#endif /* __RFKILL_INPUT_H */
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 03ed7fd..00ee534 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2006 Ivo van Doorn
+ * Copyright (C) 2006 - 2007 Ivo van Doorn
  * Copyright (C) 2007 Dmitry Torokhov
  *
  * This program is free software; you can redistribute it and/or modify
