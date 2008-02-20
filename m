From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 04/04] smc91x: add insw/outsw to default config
Date: Wed, 20 Feb 2008 18:58:21 +0900
Message-ID: <20080220095821.22645.60604.sendpatchset@clockwork.opensource.se>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.227]:59948 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbYBTKDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 05:03:41 -0500
Received: by qb-out-0506.google.com with SMTP id e11so2598712qbe.15
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 02:03:38 -0800 (PST)
In-Reply-To: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure SMC_insw()/SMC_outsw() are defined for the
default configuration. Without this change BUG()s will be triggered
when using 16-bit only platform data and the default configuration.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.h |    2 ++
 1 file changed, 2 insertions(+)

--- 0019/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-20 17:11:19.000000000 +0900
@@ -446,6 +446,8 @@ static inline void LPD7_SMC_outsw (unsig
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 
