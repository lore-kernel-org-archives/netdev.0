From: Mohammed Gamal <mgamal@redhat.com>
Subject: [PATCH] vmxnet3: Use correct minimum MTU value
Date: Tue, 17 Oct 2017 16:33:43 +0200
Message-ID: <1508250823-1954-1-git-send-email-mgamal@redhat.com>
Cc: linux-kernel@vger.kernel.org, cavery@redhat.com, otubo@redhat.com,
        vkuznets@redhat.com, Mohammed Gamal <mgamal@redhat.com>
To: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the vmxnet3 driver has a minimum MTU value of 60. Which
goes against the RFC791 spec which specifies it at 68.

Setting MTU to values between 60 <= MTU <= 67 causes the network
interface to lose its IP, and it fails to restart.

This sets the minimum value to ETH_MIN_MTU (68) which is compatible
with is according to spec.

Reported-by: Bo Yang <boyang@redhat.com>
Signed-off-by: Mohammed Gamal <mgamal@redhat.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index c3a3164..4ad905a 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -749,7 +749,7 @@ struct Vmxnet3_DriverShared {
 	((vfTable[vid >> 5] & (1 << (vid & 31))) != 0)
 
 #define VMXNET3_MAX_MTU     9000
-#define VMXNET3_MIN_MTU     60
+#define VMXNET3_MIN_MTU     ETH_MIN_MTU
 
 #define VMXNET3_LINK_UP         (10000 << 16 | 1)    /* 10 Gbps, up */
 #define VMXNET3_LINK_DOWN       0
-- 
1.8.3.1
