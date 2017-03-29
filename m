From: Varsha Rao <rvarsha016@gmail.com>
Subject: [PATCH 1/2] net: ipv4: Use macro DIV_ROUND_UP.
Date: Thu, 30 Mar 2017 00:45:11 +0530
Message-ID: <58dc07c2.5a45620a.73bc6.598a@mx.google.com>
References: <cover.1490813977.git.rvarsha016@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel <outreachy-kernel@googlegroups.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34698 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752944AbdC2TPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 15:15:16 -0400
Received: by mail-pg0-f68.google.com with SMTP id o123so4083029pga.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 12:15:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1490813977.git.rvarsha016@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro DIV_ROUND_UP performs the computation (((n) + (d) - 1) /(d)).
It simplifies the divisor calculations. This was done using the following
coccinelle script:

@@
expression e1;
expression e2;
@@
(
- ((e1) + e2 - 1) / (e2)
+ DIV_ROUND_UP(e1,e2)
|
- ((e1) + (e2 - 1)) / (e2)
+ DIV_ROUND_UP(e1,e2)
)

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
---
 net/ipv4/tcp_bbr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index b89bce4..4da4bc1 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -314,7 +314,7 @@ static u32 bbr_target_cwnd(struct sock *sk, u32 bw, int gain)
 	w = (u64)bw * bbr->min_rtt_us;
 
 	/* Apply a gain to the given value, then remove the BW_SCALE shift. */
-	cwnd = (((w * gain) >> BBR_SCALE) + BW_UNIT - 1) / BW_UNIT;
+	cwnd = DIV_ROUND_UP((w * gain) >> BBR_SCALE, BW_UNIT);
 
 	/* Allow enough full-sized skbs in flight to utilize end systems. */
 	cwnd += 3 * bbr->tso_segs_goal;
-- 
2.9.3
