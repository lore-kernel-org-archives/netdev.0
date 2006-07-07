From: akpm@osdl.org
Subject: [patch 1/2] via-ircc: fix memory leak
Date: Thu, 06 Jul 2006 23:59:09 -0700
Message-ID: <200607070659.k676x9QB030442@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, chuck@maggie,
	bcollins@ubuntu.com, samuel@sortiz.org, zulcss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30146 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751227AbWGGG7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:59:34 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Short <chuck@maggie>

Fix memory leak.

Coverity id# 653

patch location:
http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=a1f34cb68b16807ed9d5ebb0f6a6ec5ff8a5fc78

Signed-off-by: Chuck Short <zulcss@gmail.com>
Signed-off-by: Ben Collins <bcollins@ubuntu.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/irda/via-ircc.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff -puN drivers/net/irda/via-ircc.c~via-ircc-fix-memory-leak drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c~via-ircc-fix-memory-leak
+++ a/drivers/net/irda/via-ircc.c
@@ -1220,8 +1220,13 @@ static int upload_rxdata(struct via_ircc
 
 	IRDA_DEBUG(2, "%s(): len=%x\n", __FUNCTION__, len);
 
+	if ((len - 4) < 2) {
+		self->stats.rx_dropped++;
+		return FALSE;
+	}
+
 	skb = dev_alloc_skb(len + 1);
-	if ((skb == NULL) || ((len - 4) < 2)) {
+	if (skb == NULL) {
 		self->stats.rx_dropped++;
 		return FALSE;
 	}
_
