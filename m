From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH 1/2] tcp-lp 2.6.18-rc6: fix tcp_lp_remote_hz_estimator() about rhz
Date: Mon, 4 Sep 2006 17:44:58 +0800
Message-ID: <3feffd230609040244o497070f2j7909c6268f4eb588@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:51595 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751280AbWIDJo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 05:44:59 -0400
Received: by py-out-1112.google.com with SMTP id n25so2554679pyg
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2006 02:44:59 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pageexec report an oops for tcp_lp_owd_calculator(). This is due to
tcp_lp_remote_hz_estimator can return 0.

This patch fix the handling of lp->flag, so will set lp->flag as FALSE
if rhz <= 0

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN 2.6.18-rc6/tcp_lp.c tcp-lp/tcp_lp.c
--- 2.6.18-rc6/tcp_lp.c	2006-09-04 16:21:00.000000000 +0800
+++ tcp-lp/tcp_lp.c	2006-09-04 17:22:19.000000000 +0800
@@ -153,14 +157,17 @@ static u32 tcp_lp_remote_hz_estimator(st
 	if (m < 0)
 		m = -m;

-	if (rhz != 0) {
+	if (rhz > 0) {
 		m -= rhz >> 6;	/* m is now error in remote HZ est */
 		rhz += m;	/* 63/64 old + 1/64 new */
 	} else
 		rhz = m << 6;

 	/* record time for successful remote HZ calc */
-	lp->flag |= LP_VALID_RHZ;
+	if (rhz > 0)
+		lp->flag |= LP_VALID_RHZ;
+	else
+		lp->flag &= ~LP_VALID_RHZ;

  out:
 	/* record reference time stamp */

-- 
VGER BF report: U 0.500057
