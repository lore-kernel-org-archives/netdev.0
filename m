From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH 2/2] irda: add missing BKL in irnet_ppp ioctl
Date: Mon,  1 Feb 2010 16:21:35 -0200
Message-ID: <1265048496-8149-2-git-send-email-cascardo@holoscopio.com>
References: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alan Cox <alan@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One ioctl has been forgotten when the BKL was push down into irnet_ppp
ioctl function.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 net/irda/irnet/irnet_ppp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 8d38fdd..67aee5c 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -695,9 +695,11 @@ dev_irnet_ioctl(
 
       /* Query PPP channel and unit number */
     case PPPIOCGCHAN:
+      lock_kernel();
       if(ap->ppp_open && !put_user(ppp_channel_index(&ap->chan),
 						(int __user *)argp))
 	err = 0;
+      unlock_kernel();
       break;
     case PPPIOCGUNIT:
       lock_kernel();
-- 
1.6.6.1
