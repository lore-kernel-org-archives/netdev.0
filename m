From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/2] Bluetooth: make baswap src const
Date: Fri,  1 Sep 2017 13:41:17 -0700
Message-ID: <20170901204118.17123-2-bjorn.andersson@linaro.org>
References: <20170901204118.17123-1-bjorn.andersson@linaro.org>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        Loic Poulain <loic.poulain@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901204118.17123-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Loic Poulain <loic.poulain@linaro.org>

Signed-off-by: Loic Poulain <loic.poulain@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 include/net/bluetooth/bluetooth.h | 2 +-
 net/bluetooth/lib.c               | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 01487192f628..020142bb9735 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -233,7 +233,7 @@ static inline void bacpy(bdaddr_t *dst, const bdaddr_t *src)
 	memcpy(dst, src, sizeof(bdaddr_t));
 }
 
-void baswap(bdaddr_t *dst, bdaddr_t *src);
+void baswap(bdaddr_t *dst, const bdaddr_t *src);
 
 /* Common socket structures and functions */
 
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index aa4cf64e32a6..6048cc07568b 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -30,10 +30,10 @@
 
 #include <net/bluetooth/bluetooth.h>
 
-void baswap(bdaddr_t *dst, bdaddr_t *src)
+void baswap(bdaddr_t *dst, const bdaddr_t *src)
 {
+	const unsigned char *s = (const unsigned char *)src;
 	unsigned char *d = (unsigned char *) dst;
-	unsigned char *s = (unsigned char *) src;
 	unsigned int i;
 
 	for (i = 0; i < 6; i++)
-- 
2.12.0
