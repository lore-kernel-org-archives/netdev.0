From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 1/7] net: qrtr: Invoke sk_error_report() after setting sk_err
Date: Tue, 10 Oct 2017 23:45:17 -0700
Message-ID: <20171011064523.7902-2-bjorn.andersson@linaro.org>
References: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than manually waking up any context sleeping on the sock to
signal an error we should call sk_error_report(). This has the added
benefit that in-kernel consumers can override this notification with
its own callback.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v1:
- None

 net/qrtr/qrtr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index c2f5c13550c0..7e4b49a8349e 100644
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
