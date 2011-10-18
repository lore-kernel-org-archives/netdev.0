From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pptp: fix skb leak in pptp_xmit()
Date: Tue, 18 Oct 2011 05:01:47 +0200
Message-ID: <1318906907.2571.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Kozlov <xeb@mail.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40060 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235Ab1JRDBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 23:01:51 -0400
Received: by wwe6 with SMTP id 6so205659wwe.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 20:01:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we cant transmit skb, we must free it

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Dmitry Kozlov <xeb@mail.ru>
---
 drivers/net/pptp.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index eae542a..9c0403d 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -285,8 +285,10 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	ip_send_check(iph);
 
 	ip_local_out(skb);
+	return 1;
 
 tx_error:
+	kfree_skb(skb);
 	return 1;
 }
 
