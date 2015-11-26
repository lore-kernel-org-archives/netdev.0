From: Jitendra Kumar Khasdev <jkhasdev@gmail.com>
Subject: [PATCH] staging: dgnc: dgnc_cls.c: Replaced udelay by usleep_range
Date: Thu, 26 Nov 2015 22:04:25 +0530
Message-ID: <1448555665-5021-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jitendra Kumar Khasdev <jitendra.khasdev@hotwaxsystems.com>,
	Jitendra Kumar Khasdev <jkhasdev@gmail.com>
To: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@redhat.com, linus.luessing@c0d3.bluen,
	hannes@stressinduktion.org, willemb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to file dgnc_cls.c that fixes up udelay function by
usleep_range.
It is safe to use according to the following documentation
Documentation/timers/timers-howto.txt. So that is why I have given
an appropriate time range.

Signed-off-by: Jitendra Kumar Khasdev <jkhasdev@gmail.com>
---
 drivers/staging/dgnc/dgnc_cls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/dgnc/dgnc_cls.c b/drivers/staging/dgnc/dgnc_cls.c
index 75040da..72f0aaa 100644
--- a/drivers/staging/dgnc/dgnc_cls.c
+++ b/drivers/staging/dgnc/dgnc_cls.c
@@ -934,7 +934,7 @@ static void cls_flush_uart_write(struct channel_t *ch)
 
 	writeb((UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_XMIT),
 	       &ch->ch_cls_uart->isr_fcr);
-	udelay(10);
+	usleep_range(10, 20);
 
 	ch->ch_flags |= (CH_TX_FIFO_EMPTY | CH_TX_FIFO_LWM);
 }
-- 
1.9.1
