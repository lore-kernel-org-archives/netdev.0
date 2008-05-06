From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/4] Hold RTNL while calling dev_close()
Date: Tue, 6 May 2008 19:41:48 +0100
Message-ID: <20080506184147.GJ2217@solarflare.com>
References: <20080506182654.GF2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, linux-x25@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54055 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756370AbYEFSnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:43:17 -0400
Content-Disposition: inline
In-Reply-To: <20080506182654.GF2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close() must be called holding the RTNL.  Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/wan/x25_asy.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 249e180..069f8bb 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -32,6 +32,7 @@
 #include <linux/x25.h>
 #include <linux/lapb.h>
 #include <linux/init.h>
+#include <linux/rtnetlink.h>
 #include "x25_asy.h"
 
 #include <net/x25device.h>
@@ -601,8 +602,10 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 	if (!sl || sl->magic != X25_ASY_MAGIC)
 		return;
 
+	rtnl_lock();
 	if (sl->dev->flags & IFF_UP)
 		dev_close(sl->dev);
+	rtnl_unlock();
 
 	tty->disc_data = NULL;
 	sl->tty = NULL;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
