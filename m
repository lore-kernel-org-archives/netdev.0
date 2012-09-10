From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] staging: r8712u: fix bug in r8712_recv_indicatepkt()
Date: Mon, 10 Sep 2012 19:55:15 +0200
Message-ID: <1347299715.1234.1902.camel@edumazet-glaptop>
References: <50369925.3050705@lwfinger.net>
	 <1345757200.5904.1890.camel@edumazet-glaptop> <50378B35.80307@lwfinger.net>
	 <20120824.111948.680531915905273128.davem@davemloft.net>
	 <5037A4B0.3080208@lwfinger.net>
	 <1345825095.19483.19.camel@edumazet-glaptop>
	 <1345825432.19483.20.camel@edumazet-glaptop> <5037B2AC.50704@lwfinger.net>
	 <1345830424.19483.69.camel@edumazet-glaptop>
	 <503BB49C.5010402@lwfinger.net>
	 <1347266366.1234.1267.camel@edumazet-glaptop>
	 <504DFEFF.6060004@lwfinger.net>
	 <1347289446.1234.1717.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34616 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964Ab2IJRzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 13:55:24 -0400
In-Reply-To: <1347289446.1234.1717.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

64bit arches have a buggy r8712u driver, let's fix it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/staging/rtl8712/recv_linux.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
index 0e26d5f..495ee12 100644
--- a/drivers/staging/rtl8712/recv_linux.c
+++ b/drivers/staging/rtl8712/recv_linux.c
@@ -117,13 +117,8 @@ void r8712_recv_indicatepkt(struct _adapter *padapter,
 	if (skb == NULL)
 		goto _recv_indicatepkt_drop;
 	skb->data = precv_frame->u.hdr.rx_data;
-#ifdef NET_SKBUFF_DATA_USES_OFFSET
-	skb->tail = (sk_buff_data_t)(precv_frame->u.hdr.rx_tail -
-		     precv_frame->u.hdr.rx_head);
-#else
-	skb->tail = (sk_buff_data_t)precv_frame->u.hdr.rx_tail;
-#endif
 	skb->len = precv_frame->u.hdr.len;
+	skb_set_tail_pointer(skb, skb->len);
 	if ((pattrib->tcpchk_valid == 1) && (pattrib->tcp_chkrpt == 1))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
