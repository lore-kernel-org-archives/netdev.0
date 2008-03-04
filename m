From: akpm@linux-foundation.org
Subject: [patch 07/17] smc91x: add insw/outsw to default config
Date: Tue, 04 Mar 2008 15:19:26 -0800
Message-ID: <200803042319.m24NJQjh002694@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org,
	nico@cam.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57435 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935115AbYCDXTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

This patch makes sure SMC_insw()/SMC_outsw() are defined for the default
configuration.  Without this change BUG()s will be triggered when using 16-bit
only platform data and the default configuration.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Acked-by: Nicolas Pitre <nico@cam.org>
Cc: Paul Mundt <lethal@linux-sh.org>,
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc91x.h |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/smc91x.h~smc91x-add-insw-outsw-to-default-config-v2 drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~smc91x-add-insw-outsw-to-default-config-v2
+++ a/drivers/net/smc91x.h
@@ -476,6 +476,8 @@ static inline void LPD7_SMC_outsw (unsig
 #define SMC_outb(v, a, r)	writeb(v, (a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
 #define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 #define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
 #define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 
_
