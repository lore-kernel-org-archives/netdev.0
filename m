From: arno@natisbad.org (Arnaud Ebalard)
Subject: Question about skb_segment()
Date: Wed, 29 Jan 2014 09:12:57 +0100
Message-ID: <87fvo71a0m.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, Willy Tarreau <w@1wt.eu>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:57091 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbaA2INV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 03:13:21 -0500
Received: from smtp.natisbad.org (unknown [IPv6:2a01:e35:139b:9f90:221:70ff:fe55:8f78])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 50F9C4B00EC
	for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 09:13:07 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

I wonder if you could share some knowledge on the behaviour of
skb_segment() as it is implemented in 3.13.0: when passed a GSO
packet to be segmented, can the skb result have skb->next == NULL?

One would expect the number of segments of the result to usually match
tcp_skb_pcount() of passed packet and hence having skb->next != NULL: 
AFAICT, this what usually happens when skb_segment() is called in
tcp_gso_segment() but I noticed some cases where the number of segments
(length of chained sk_buff) is lower than the expected value and also
have two backtraces resulting from a skb delivered with a NULL skb->next. 

The whole thread leading to my question is here, in case you want to
take a look:

 http://thread.gmane.org/gmane.linux.network/301587

Thanks in advance,

a+
