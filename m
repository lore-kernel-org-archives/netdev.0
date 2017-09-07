From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/7] net: qrtr: Invoke sk_error_report() after setting sk_err
Date: Wed,  6 Sep 2017 23:03:23 -0700
Message-ID: <20170907060329.32402-2-bjorn.andersson@linaro.org>
References: <20170907060329.32402-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34254 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbdIGGDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 02:03:35 -0400
Received: by mail-pf0-f172.google.com with SMTP id e1so2343850pfk.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 23:03:35 -0700 (PDT)
In-Reply-To: <20170907060329.32402-1-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than manually waking up any context sleeping on the sock to
signal an error we should call sk_error_report(). This has the added
benefit that in-kernel consumers can override this notificatino with
its own callback.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 net/qrtr/qrtr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 5586609afa27..2058b27821a4 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -541,7 +541,7 @@ static void qrtr_reset_ports(void)
 
 		sock_hold(&ipc->sk);
 		ipc->sk.sk_err = ENETRESET;
-		wake_up_interruptible(sk_sleep(&ipc->sk));
+		ipc->sk.sk_error_report(&ipc->sk);
 		sock_put(&ipc->sk);
 	}
 	mutex_unlock(&qrtr_port_lock);
-- 
2.12.0
