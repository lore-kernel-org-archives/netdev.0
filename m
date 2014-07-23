From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] isdn: use constants instead of magicnumbers
Date: Thu, 24 Jul 2014 02:46:38 +0530
Message-ID: <20140723211638.GA4283@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54319 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933498AbaGWVQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:16:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes instances of magic numbers like 4 and 8 to equivalent
constants.

The Coccinelle semantic patch used for making the change is as follows:

// <smpl>
@r@
type T;
T E;
identifier fld;
identifier c;
@@

E->fld & c

@s@
constant C;
identifier r.c;
@@

#define c C

@@
r.T E;
identifier r.fld;
identifier r.c;
constant s.C;
@@

 E->fld &
- C
+ c
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: Karsten Keil <isdn@linux-pingi.de>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 drivers/isdn/i4l/isdn_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index c2ed624..94affa5 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -2918,8 +2918,8 @@ isdn_net_getcfg(isdn_net_ioctl_cfg *cfg)
 			cfg->callback = 2;
 		cfg->cbhup = (lp->flags & ISDN_NET_CBHUP) ? 1 : 0;
 		cfg->dialmode = lp->flags & ISDN_NET_DIALMODE_MASK;
-		cfg->chargehup = (lp->hupflags & 4) ? 1 : 0;
-		cfg->ihup = (lp->hupflags & 8) ? 1 : 0;
+		cfg->chargehup = (lp->hupflags & ISDN_CHARGEHUP) ? 1 : 0;
+		cfg->ihup = (lp->hupflags & ISDN_INHUP) ? 1 : 0;
 		cfg->cbdelay = lp->cbdelay;
 		cfg->dialmax = lp->dialmax;
 		cfg->triggercps = lp->triggercps;
-- 
1.9.1
