From: Daniel Turull <daniel.turull@gmail.com>
Subject: [PATCH] pktgen: fix errata in show results
Date: Mon, 07 Mar 2011 10:09:43 +0100
Message-ID: <4D74A0D7.3020506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?7J207KKF7JuQ?= <ljw@handong.edu>,
	Robert Olsson <robert@herjulf.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:42999 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab1CGJJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:09:47 -0500
Received: by yia27 with SMTP id 27so1540632yia.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 01:09:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The units in show_results in pktgen were not correct.
The results are in usec but it was displayed nsec.

Reported-by: Jong-won Lee <ljw@handong.edu>
Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d73b77a..f0aec6c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3271,7 +3271,7 @@ static void show_results(struct pktgen_dev 
*pkt_dev, int nr_frags)
                      pkt_dev->started_at);
      ktime_t idle = ns_to_ktime(pkt_dev->idle_acc);

-    p += sprintf(p, "OK: %llu(c%llu+d%llu) nsec, %llu (%dbyte,%dfrags)\n",
+    p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)\n",
               (unsigned long long)ktime_to_us(elapsed),
               (unsigned long long)ktime_to_us(ktime_sub(elapsed, idle)),
               (unsigned long long)ktime_to_us(idle),
