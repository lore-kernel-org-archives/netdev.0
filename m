From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH] tcp-lp: prevent chance for oops
Date: Thu, 28 Sep 2006 18:43:58 +0800
Message-ID: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.199]:28546 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751488AbWI1Kn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 06:43:59 -0400
Received: by nz-out-0102.google.com with SMTP id n1so205581nzf
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 03:43:59 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the chance for tcp_lp_remote_hz_estimator return 0, if
0 < rhz < 64. It also make sure the flag LP_VALID_RHZ is set
correctly.

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.18/net/ipv4/tcp_lp.c linux/net/ipv4/tcp_lp.c
--- linux-2.6.18/net/ipv4/tcp_lp.c	2006-09-20 11:42:06.000000000 +0800
+++ linux/net/ipv4/tcp_lp.c	2006-09-28 18:30:17.000000000 +0800
@@ -32,7 +32,7 @@
  * SourceForge project page:
  *   http://tcp-lp-mod.sourceforge.net/
  *
- * Version: $Id: tcp_lp.c,v 1.24 2006/09/05 20:22:53 hswong3i Exp $
+ * Version: $Id: tcp_lp.c,v 1.25 2006/09/22 20:50:27 hswong3i Exp $
  */

 #include <linux/config.h>
@@ -165,7 +165,7 @@ static u32 tcp_lp_remote_hz_estimator(st

  out:
 	/* record time for successful remote HZ calc */
-	if (rhz > 0)
+	if ((rhz >> 6) > 0)
 		lp->flag |= LP_VALID_RHZ;
 	else
 		lp->flag &= ~LP_VALID_RHZ;
