From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 0/8] iucv / af_iucv patches for net-next-2.6.30-rc1
Date: Thu, 23 Apr 2009 15:07:03 +0200
Message-ID: <1240492023.11770.5.camel@braunu-laptop>
References: <1240400356.13951.11.camel@braunu-laptop>
	 <20090423.044343.133646582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:61661 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbZDWNHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 09:07:54 -0400
In-Reply-To: <20090423.044343.133646582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-23 at 04:43 -0700, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Wed, 22 Apr 2009 13:39:16 +0200
> 
> > the af_iucv-patches sent today apply to net-next-2.6 without pulling
> > yesterday's patches for net-2.6.
> > 
> > If you prefer to pull net-2.6 first (in order to avoid potential future
> > merge conflicts), I can rebuild and resend today's net-next-2.6 patches
> > based on yesterday's af_iucv patches for net-2.6.
> 
> I applied them all, then pulled net-2.6 into net-next-2.6 to
> resolve the conflicts.
> 
> Please make sure I did the right thing :-)

Dave,

net/iucv/af_iucv.c in net-next-2.6 is almost correct. 4 lines should
still be deleted. These are the remaining changes:
---
 net/iucv/af_iucv.c |    4 ----
 1 file changed, 4 deletions(-)

Index: net-next-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-next-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-next-2.6-uschi/net/iucv/af_iucv.c
@@ -982,8 +982,6 @@ static int iucv_sock_recvmsg(struct kioc
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
-	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
-
 	/* receive/dequeue next skb:
 	 * the function understands MSG_PEEK and, thus, does not dequeue skb
*/
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
@@ -1429,8 +1427,6 @@ static void iucv_callback_rx(struct iucv
 	iucv_process_message(sk, skb, path, msg);
 	goto out_unlock;
 
-	return;
-
 save_message:
 	save_msg = kzalloc(sizeof(struct sock_msg_q), GFP_ATOMIC | GFP_DMA);
 	if (!save_msg)

Thanks a lot for your effort.

Regards, Ursula Braun

