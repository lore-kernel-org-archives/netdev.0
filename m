From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 1/2] net, iucv: fixing error from refcount conversion
Date: Mon,  3 Jul 2017 14:50:27 +0300
Message-ID: <1499082628-21253-2-git-send-email-elena.reshetova@intel.com>
References: <1499082628-21253-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499082628-21253-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixing "net/iucv/af_iucv.c:405:22: error: passing
argument 1 of 'atomic_read' from incompatible pointer type"
---
 net/iucv/af_iucv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index ac033e4..1485331 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -402,7 +402,7 @@ static void iucv_sock_destruct(struct sock *sk)
 	}
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
+	WARN_ON(refcount_read(&sk->sk_wmem_alloc));
 	WARN_ON(sk->sk_wmem_queued);
 	WARN_ON(sk->sk_forward_alloc);
 }
-- 
2.7.4
