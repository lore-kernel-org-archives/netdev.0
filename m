From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH] isdn: Return -EINTR in gigaset_start() if locking attempts fails.
Date: Fri, 16 Mar 2012 18:40:13 +0530
Message-ID: <1331903413-11426-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: hjlipp@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33966 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab2CPNLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 09:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

If locking attempt was interrupted by a signal then we should
return -EINTR so that caller can take appropriate action.

We have 3 callers: gigaset_probe(), gigaset_tty_open() and
gigaset_probe(). Each caller tries to free allocated memory
if lock fails. This is possible if we returns -EINTR.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/isdn/gigaset/common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 7679270..2d10f3a 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -903,7 +903,7 @@ int gigaset_start(struct cardstate *cs)
 	unsigned long flags;
 
 	if (mutex_lock_interruptible(&cs->mutex))
-		return 0;
+		return -EINTR;
 
 	spin_lock_irqsave(&cs->lock, flags);
 	cs->connected = 1;
-- 
1.7.4.4
