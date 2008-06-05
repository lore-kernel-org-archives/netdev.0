From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/3] af_iucv: exploit target message class support of IUCV
Date: Thu, 05 Jun 2008 11:08:40 +0200
Message-ID: <20080605091438.629434000@linux.vnet.ibm.com>
References: <20080605090837.212105000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:61627 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbYFEJOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 05:14:51 -0400
Content-Disposition: inline; filename=603-af_iucv-class.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

The first 4 bytes of data to be sent are stored additionally into
the message class field of the send request. A receiving target
program (not an af_iucv socket program) can make use of this
information to pre-screen incoming messages.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/af_iucv.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -644,6 +644,7 @@ static int iucv_sock_sendmsg(struct kioc
 		}
 
 		txmsg.class = 0;
+		memcpy(&txmsg.class, skb->data, skb->len >= 4 ? 4 : skb->len);
 		txmsg.tag = iucv->send_tag++;
 		memcpy(skb->cb, &txmsg.tag, 4);
 		skb_queue_tail(&iucv->send_skb_q, skb);

-- 
