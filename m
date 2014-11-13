From: Vincent Benayoun <vincent.benayoun@trust-in-soft.com>
Subject: [PATCH] inetdevice: fixed signed integer overflow
Date: Thu, 13 Nov 2014 15:04:57 +0000
Message-ID: <1e488fa546724140b55c8d4bd6b5a9d6@S1688.EX1688.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "\"David S. Miller\"" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>, Julian Anastasov <ja@ssi.bg>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: fr-FR
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From f25ff0f2645f9763552147d480f86973b7041e26 Mon Sep 17 00:00:00 2001
From: Vincent BENAYOUN <vincent.benayoun@trust-in-soft.com>
Date: Thu, 13 Nov 2014 13:47:26 +0100
Subject: [PATCH] inetdevice: fixed signed integer overflow

There could be a signed overflow in the following code.

The expression, (32-logmask) is comprised between 0 and 31 included.
It may be equal to 31.
In such a case the left shift will produce a signed integer overflow.
According to the C99 Standard, this is an undefined behavior.
A simple fix is to replace the signed int 1 with the unsigned int 1U.

Best Regards,
Vincent Benayoun
R&D engineer @ TrustInSoft

Signed-off-by: Vincent BENAYOUN <vincent.benayoun@trust-in-soft.com>
---
 include/linux/inetdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 0068708..0a21fbe 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -242,7 +242,7 @@ static inline void in_dev_put(struct in_device *idev)
 static __inline__ __be32 inet_make_mask(int logmask)
 {
 	if (logmask)
-		return htonl(~((1<<(32-logmask))-1));
+		return htonl(~((1U<<(32-logmask))-1));
 	return 0;
 }
 
-- 
1.9.1
