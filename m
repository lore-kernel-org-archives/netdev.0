From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 03/04] smc91x: add insw/outsw to default config V2
Date: Fri, 22 Feb 2008 19:55:24 +0900
Message-ID: <20080222105524.7408.24180.sendpatchset@clockwork.opensource.se>
References: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:16945 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575AbYBVLAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 06:00:53 -0500
Received: by wr-out-0506.google.com with SMTP id c48so584558wra.23
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 03:00:52 -0800 (PST)
In-Reply-To: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure SMC_insw()/SMC_outsw() are defined for the
default configuration. Without this change BUG()s will be triggered
when using 16-bit only platform data and the default configuration.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.h |    2 ++
 1 file changed, 2 insertions(+)

--- 0003/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-22 15:25:39.000000000 +0900
@@ -476,6 +476,8 @@ static inline void LPD7_SMC_outsw (unsig
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 
