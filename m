From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 06/14] Bluetooth: RFCOMM - Fix info leak in ioctl(RFCOMMGETDEVLIST)
Date: Wed, 15 Aug 2012 23:31:49 +0200
Message-ID: <1345066317-22512-7-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RFCOMM code fails to initialize the two padding bytes of struct
rfcomm_dev_list_req inserted for alignment before copying it to
userland. Additionally there are two padding bytes in each instance of
struct rfcomm_dev_info. The ioctl() that for disclosures two bytes plus
dev_num times two bytes uninitialized kernel heap memory.

Allocate the memory using kzalloc() to fix this issue.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
---
 net/bluetooth/rfcomm/tty.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index cb96077..56f1823 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -456,7 +456,7 @@ static int rfcomm_get_dev_list(void __user *arg)
 
 	size = sizeof(*dl) + dev_num * sizeof(*di);
 
-	dl = kmalloc(size, GFP_KERNEL);
+	dl = kzalloc(size, GFP_KERNEL);
 	if (!dl)
 		return -ENOMEM;
 
-- 
1.7.10.4
