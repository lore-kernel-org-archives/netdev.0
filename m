From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][PPPOL2TP] add missing sock_put() in pppol2tp_recv_dequeue()
Date: Wed, 27 Feb 2008 10:54:32 +0000
Message-ID: <20080227105431.GA4527@ff.dom.local>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:51344 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671AbYB0Kx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 05:53:29 -0500
Received: by ug-out-1314.google.com with SMTP id z38so275870ugc.16
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 02:53:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C402A2.8040401@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is some tiny BTW fix (probably not connected with these lockups).

Regards,
Jarek P.

-------------->

Subject: [PPPOL2TP] add missing sock_put() in pppol2tp_recv_dequeue()

Every skb removed from session->reorder_q needs sock_put().


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 drivers/net/pppol2tp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0b072d..dcd4991 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -455,6 +455,7 @@ static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
 			       skb_queue_len(&session->reorder_q));
 			__skb_unlink(skb, &session->reorder_q);
 			kfree_skb(skb);
+			sock_put(session->sock);
 			continue;
 		}
 
