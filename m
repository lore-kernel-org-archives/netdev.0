From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/6] net: qrtr: Invoke sk_error_report() after setting sk_err
Date: Fri,  4 Aug 2017 07:59:33 -0700
Message-ID: <20170804145938.25427-2-bjorn.andersson@linaro.org>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
Cc: linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804145938.25427-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
