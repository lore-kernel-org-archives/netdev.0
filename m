From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn: gigaset: add missing unlock
Date: Fri, 6 Aug 2010 10:23:23 +0200
Message-ID: <20100806082323.GU9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Shevchenko <ext-andriy.shevchenko@nokia.com>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Hansjoerg Lipp <hjlipp@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49144 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab0HFIYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 04:24:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should unlock here.  This is the only place where we return from the
function with the lock held.  The caller isn't expecting it.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index e5ea344..bcc174e 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1052,6 +1052,7 @@ static inline void remove_appl_from_channel(struct bc_state *bcs,
 	do {
 		if (bcap->bcnext == ap) {
 			bcap->bcnext = bcap->bcnext->bcnext;
+			spin_unlock_irqrestore(&bcs->aplock, flags);
 			return;
 		}
 		bcap = bcap->bcnext;
