From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 31/41] CAPI: Drop handle_minor_recv from capinc_tty_write
Date: Mon,  8 Feb 2010 21:12:35 +0100
Message-ID: <b261bd6997f28ec6391c04bc0ec6fef668a92e63.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sending a message down the CAPI stack may trigger the reception of an
answer, but this will go through capi_recv_message and call
handle_minor_recv from there. There is no need to walk the receive queue
on capinc_tty_write.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 867589a..554fa1b 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1104,7 +1104,6 @@ static int capinc_tty_write(struct tty_struct *tty,
 	skb_queue_tail(&mp->outqueue, skb);
 	mp->outbytes += skb->len;
 	(void)handle_minor_send(mp);
-	(void)handle_minor_recv(mp);
 	spin_unlock_irqrestore(&workaround_lock, flags);
 	return count;
 }
-- 
1.6.0.2
