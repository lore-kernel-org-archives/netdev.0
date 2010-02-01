From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH 1/2] irda: unbalanced lock_kernel in irnet_ppp
Date: Mon,  1 Feb 2010 16:21:34 -0200
Message-ID: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the missing unlock_kernel in one ioctl operation.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 net/irda/irnet/irnet_ppp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index d6b502c..8d38fdd 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -703,7 +703,8 @@ dev_irnet_ioctl(
       lock_kernel();
       if(ap->ppp_open && !put_user(ppp_unit_number(&ap->chan),
 						(int __user *)argp))
-      err = 0;
+        err = 0;
+      unlock_kernel();
       break;
 
       /* All these ioctls can be passed both directly and from ppp_generic,
-- 
1.6.6.1
