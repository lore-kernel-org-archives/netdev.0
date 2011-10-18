From: Daniel Turull <daniel.turull@gmail.com>
Subject: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Tue, 18 Oct 2011 13:08:11 +0200
Message-ID: <4E9D5E1B.3080704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52179 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab1JRLIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 07:08:15 -0400
Received: by bkbzt19 with SMTP id zt19so650902bkb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 04:08:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The value selected to delay the transmission in pktgen with the ndelay function should be lower.
In Linux/arch/x86/include/asm/delay.h and Linux/arch/sh/include/asm/delay.h
the maximal expected value for a constant is 20000 ns.

Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 796044a..e17bd41 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2145,7 +2145,7 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 	}
 
 	start_time = ktime_now();
-	if (remaining < 100000)
+	if (remaining < 20000)
 		ndelay(remaining);	/* really small just spin */
 	else {
 		/* see do_nanosleep */
