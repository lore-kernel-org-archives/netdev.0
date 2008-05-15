From: "Christophe Jaillet" <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 1/1] /drivers/net/r6040.c: bad use of round_jiffies() ???
Date: Thu, 15 May 2008 23:26:22 +0200
Message-ID: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Content-Type: text/plain
To: "cj" <christophe.jaillet@wanadoo.fr>,
	"linux" <linux-kernel@vger.kernel.org>,
	<florian.fainelli@telecomint.eu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.96]:36322 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbYEOV03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 17:26:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Jaillet <christophe.jaillet@wanadoo.fr>

Hi, here is a patch against linux/drivers/net/r6040.c.

Compared to other places in the kernel, I think that this driver misuses
the function round_jiffies.


Note: this patch is based on 'linux-2.6.25.tar.bz2'

Signed-off-by: Christophe Jaillet <christophe.jaillet@wanadoo.fr>

---

--- linux 2.6.25/drivers/net/r6040.c	2008-05-15 23:21:28.000000000 +0200
+++ linux 2.6.25/drivers/net/r6040.c.cj	2008-05-15 22:16:44.000000000 +0200
@@ -733,7 +733,7 @@ static void r6040_timer(unsigned long da
 	}
 
 	/* Timer active again */
-	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
+	mod_timer(&lp->timer, round_jiffies(jiffies + HZ));
 }
 
 /* Read/set MAC address routines */


