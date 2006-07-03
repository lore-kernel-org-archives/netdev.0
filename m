From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [Ubuntu PATCH] via-ircc: fix memory leak
Date: Mon, 03 Jul 2006 13:48:03 -0700
Message-ID: <44A98283.9020607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@osdl.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:5812 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1751291AbWGCUq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 16:46:26 -0400
To: samuel@sortiz.org, lkml <linux-kernel@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Short <chuck@maggie>

[UBUNTU: via-ircc] Fix memory leak.

Coverity id# 653

patch location:
http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=a1f34cb68b16807ed9d5ebb0f6a6ec5ff8a5fc78

Signed-off-by: Chuck Short <zulcss@gmail.com>
Signed-off-by: Ben Collins <bcollins@ubuntu.com>
---
 drivers/net/irda/via-ircc.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- linux-2617-g21.orig/drivers/net/irda/via-ircc.c
+++ linux-2617-g21/drivers/net/irda/via-ircc.c
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



