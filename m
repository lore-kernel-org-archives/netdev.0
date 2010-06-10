From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH 1/2] pktgen: increasing transmission granularity
Date: Thu, 10 Jun 2010 10:44:51 +0200
Message-ID: <4C10A603.2080402@gmail.com>
References: <4C064533.6070709@gmail.com> <20100609.135040.193710199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@herjulf.net, jens.laas@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:40798 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623Ab0FJIor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 04:44:47 -0400
Received: by ewy23 with SMTP id 23so595149ewy.1
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 01:44:46 -0700 (PDT)
In-Reply-To: <20100609.135040.193710199.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch correct a bug in the delay of pktgen. 
It makes sure the inter-packet interval is accurate.

Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2ad68da..1dacd7b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2170,7 +2170,7 @@ static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 	end_time = ktime_now();
 
 	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(end_time, start_time));
-	pkt_dev->next_tx = ktime_add_ns(end_time, pkt_dev->delay);
+	pkt_dev->next_tx = ktime_add_ns(spin_until, pkt_dev->delay);
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
