From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH] sfc: Make temperature warnings/alarms more explicit.
Date: Tue, 28 Apr 2009 16:48:04 +0200
Message-ID: <1240930084.10689.39.camel@localhost.localdomain>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite>
	 <1240929844.10689.35.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40682 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757452AbZD1OsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 10:48:07 -0400
In-Reply-To: <1240929844.10689.35.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The sfc driver can detect different hardware failures via the
LM87 system.  One of the failures I have experienced is the
temperature alarm, but the error message didn't reveal that this
error was temperature related.  I had to read the code to
discover that.

I think that the temperature error should be more explicit, in
order to warn people before the board is permanently damaged.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/sfc/boards.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index 4a4c74c..b1822fe 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -121,8 +121,10 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 	if (alarms1 || alarms2) {
 		EFX_ERR(efx,
 			"LM87 detected a hardware failure (status %02x:%02x)"
-			"%s%s\n",
+			"%s%s%s\n",
 			alarms1, alarms2,
+			(alarms1 & (LM87_ALARM_TEMP_INT|LM87_ALARM_TEMP_EXT1))
+			 ? " high temperature" : "",
 			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
 			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
 		return -ERANGE;

