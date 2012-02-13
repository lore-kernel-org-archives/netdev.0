From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ppp: fix truesize underestimation
Date: Mon, 13 Feb 2012 15:23:24 +0100
Message-ID: <1329143004.2494.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paul Mackerras <paulus@samba.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:58867 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab2BMOX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 09:23:28 -0500
Received: by wics10 with SMTP id s10so3492236wic.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 06:23:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building frag_list, head truesize should be sum of all frag
truesize.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ppp/ppp_generic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index edfa15d..93a8639 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2113,7 +2113,7 @@ ppp_mp_reconstruct(struct ppp *ppp)
 
 				skb->len += p->len;
 				skb->data_len += p->len;
-				skb->truesize += p->len;
+				skb->truesize += p->truesize;
 
 				if (p == tail)
 					break;
