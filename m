From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] mISDN: Fix a sleep-in-atomic bug
Date: Wed, 31 May 2017 15:08:25 +0800
Message-ID: <1496214505-15155-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: isdn@linux-pingi.de, mingo@kernel.org, fweisbec@gmail.com,
        geliangtang@gmail.com, akpm@linux-foundation.org,
        davem@davemloft.net, yamada.masahiro@socionext.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver may sleep under a read spin lock, and the function call path is:
send_socklist (acquire the lock by read_lock)
  skb_copy(GFP_KERNEL) --> may sleep

To fix it, the "GFP_KERNEL" is replaced with "GFP_ATOMIC".

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/isdn/mISDN/stack.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/mISDN/stack.c b/drivers/isdn/mISDN/stack.c
index 8b7faea..422dced 100644
--- a/drivers/isdn/mISDN/stack.c
+++ b/drivers/isdn/mISDN/stack.c
@@ -75,7 +75,7 @@
 		if (sk->sk_state != MISDN_BOUND)
 			continue;
 		if (!cskb)
-			cskb = skb_copy(skb, GFP_KERNEL);
+			cskb = skb_copy(skb, GFP_ATOMIC);
 		if (!cskb) {
 			printk(KERN_WARNING "%s no skb\n", __func__);
 			break;
-- 
1.7.9.5
