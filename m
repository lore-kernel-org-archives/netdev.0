From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH] pktgen: fix errata in show results
Date: Mon, 07 Mar 2011 10:44:40 +0100
Message-ID: <4D74A908.7040302@gmail.com>
References: <4D74A0D7.3020506@gmail.com> <20110307.011942.115928916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ljw@handong.edu, robert@herjulf.net,
	Daniel Turull <daniel.turull@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57614 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab1CGJoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:44:44 -0500
Received: by gxk8 with SMTP id 8so1558670gxk.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 01:44:44 -0800 (PST)
In-Reply-To: <20110307.011942.115928916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The units in show_results in pktgen were not correct.
The results are in usec but it was displayed nsec.

Reported-by: Jong-won Lee <ljw@handong.edu>
Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
---
Here it is the new version.
Sorry for the previous mail.
Daniel

---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d73b77a..f0aec6c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3271,7 +3271,7 @@ static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
 				    pkt_dev->started_at);
 	ktime_t idle = ns_to_ktime(pkt_dev->idle_acc);
 
-	p += sprintf(p, "OK: %llu(c%llu+d%llu) nsec, %llu (%dbyte,%dfrags)\n",
+	p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)\n",
 		     (unsigned long long)ktime_to_us(elapsed),
 		     (unsigned long long)ktime_to_us(ktime_sub(elapsed, idle)),
 		     (unsigned long long)ktime_to_us(idle),
