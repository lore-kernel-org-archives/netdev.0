From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 04/10] drivers:mpt: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:13 +0530
Message-ID: <1505287939-14106-4-git-send-email-allen.lkml@gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/message/fusion/mptbase.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
index 84eab28..7920b2b 100644
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -4328,15 +4328,15 @@ initChainBuffers(MPT_ADAPTER *ioc)
 	if (ioc->ReqToChain == NULL) {
 		sz = ioc->req_depth * sizeof(int);
 		mem = kmalloc(sz, GFP_ATOMIC);
-		if (mem == NULL)
-			return -1;
+		if (!mem)
+			return -ENOMEM;
 
 		ioc->ReqToChain = (int *) mem;
 		dinitprintk(ioc, printk(MYIOC_s_DEBUG_FMT "ReqToChain alloc  @ %p, sz=%d bytes\n",
 			 	ioc->name, mem, sz));
 		mem = kmalloc(sz, GFP_ATOMIC);
-		if (mem == NULL)
-			return -1;
+		if (!mem)
+			return -ENOMEM;
 
 		ioc->RequestNB = (int *) mem;
 		dinitprintk(ioc, printk(MYIOC_s_DEBUG_FMT "RequestNB alloc  @ %p, sz=%d bytes\n",
@@ -4402,8 +4402,8 @@ initChainBuffers(MPT_ADAPTER *ioc)
 	sz = num_chain * sizeof(int);
 	if (ioc->ChainToChain == NULL) {
 		mem = kmalloc(sz, GFP_ATOMIC);
-		if (mem == NULL)
-			return -1;
+		if (!mem)
+			return -ENOMEM;
 
 		ioc->ChainToChain = (int *) mem;
 		dinitprintk(ioc, printk(MYIOC_s_DEBUG_FMT "ChainToChain alloc @ %p, sz=%d bytes\n",
-- 
2.7.4
