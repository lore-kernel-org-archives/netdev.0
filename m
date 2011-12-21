From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] irda: use msecs_to_jiffies() rather than manual calculation
Date: Wed, 21 Dec 2011 07:57:16 -0500
Message-ID: <1324472236-9681-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Xi Wang <xi.wang@gmail.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:50207 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab1LUM65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 07:58:57 -0500
Received: by qadb15 with SMTP id b15so4694753qad.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 04:58:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also use mod_timer() instead of direct assignment to "expires".

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/irda/af_irda.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index c24f25a..bb14c34 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2558,8 +2558,8 @@ bed:
 			self->errno = 0;
 			setup_timer(&self->watchdog, irda_discovery_timeout,
 					(unsigned long)self);
-			self->watchdog.expires = jiffies + (val * HZ/1000);
-			add_timer(&(self->watchdog));
+			mod_timer(&self->watchdog,
+				  jiffies + msecs_to_jiffies(val));
 
 			/* Wait for IR-LMP to call us back */
 			__wait_event_interruptible(self->query_wait,
-- 
1.7.5.4
