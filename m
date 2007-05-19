From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rfkill: Fix check for correct rfkill allocation
Date: Sat, 19 May 2007 14:08:43 +0200
Message-ID: <200705191408.44138.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>,
	Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:38433 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757476AbXESMKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 08:10:23 -0400
Received: by ug-out-1314.google.com with SMTP id 44so701033uga
        for <netdev@vger.kernel.org>; Sat, 19 May 2007 05:10:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

coverity has spotted a bug in rfkill.c (bug id #1627),
in rfkill_allocate() NULL was returns if the kzalloc() works,
and deref the NULL pointer if it fails,

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index a973603..f3986d4 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -296,7 +296,7 @@ struct rfkill *rfkill_allocate(struct device *parent, enum rfkill_type type)
 	struct device *dev;
 
 	rfkill = kzalloc(sizeof(struct rfkill), GFP_KERNEL);
-	if (rfkill)
+	if (!rfkill)
 		return NULL;
 
 	mutex_init(&rfkill->mutex);
