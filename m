From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH]NET:PCNET32: poll method return 0 when done
Date: Wed, 11 Nov 2009 23:11:36 +0800
Message-ID: <1257952296.1920.3.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:65196 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbZKLPFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:05:21 -0500
Received: by pwi3 with SMTP id 3so1385075pwi.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 07:05:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Poll method return 0 when it is done.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/pcnet32.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index c1b3f09..58894a3 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1396,6 +1396,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (work_done < budget) {
+		work_done = 0;
 		spin_lock_irqsave(&lp->lock, flags);
 
 		__napi_complete(napi);


