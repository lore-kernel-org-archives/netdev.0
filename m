From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Fri, 02 Oct 2009 07:14:46 +0200
Message-ID: <4AC58C46.8080408@gmail.com>
References: <200910011814.47689.atis@mikrotik.com>	<4AC4D90E.3040008@gmail.com> <20091001.151823.263194343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: atis@mikrotik.com, panther@balabit.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38179 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755322AbZJBFO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 01:14:59 -0400
In-Reply-To: <20091001.151823.263194343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a followup on this area, thanks.

[RFC] af_packet: fill skb->mark at xmit

skb->mark may be used by classifiers, so fill it in case user 
set a SO_MARK option on socket.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/packet/af_packet.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d7ecca0..610f150 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -490,6 +490,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 	if (err)
 		goto out_free;
 
@@ -856,6 +857,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
+	skb->mark = po->sk.sk_mark;
 	skb_shinfo(skb)->destructor_arg = ph.raw;
 
 	switch (po->tp_version) {
@@ -1125,6 +1127,7 @@ static int packet_snd(struct socket *sock,
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
 
 	/*
 	 *	Now send it

