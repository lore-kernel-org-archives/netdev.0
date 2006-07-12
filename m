From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH]NET: Add ECN support for TSO
Date: Tue, 11 Jul 2006 18:45:48 -0700
Message-ID: <002201c6a554$e6af4580$4710100a@pc.s2io.com>
References: <20060708.133223.35527292.davem@davemloft.net>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:13524 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932066AbWGLBqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 21:46:25 -0400
To: "'David Miller'" <davem@davemloft.net>, <mchan@broadcom.com>
In-Reply-To: <20060708.133223.35527292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael/David,
Thanks for the comments on LRO. The current LRO code in S2io driver is not
aware of ECN. While I was trying to fix this, the first thing I encountered
was to check, in the driver, if ECN is enabled for current session. To do
this, I try to get hold of the socket by doing something like:

tk = tcp_sk(skb->sk);
if (tk->ecn_flags & TCP_ECN_OK)
   /* Check CE, ECE, CWR etc */

I find that skb->sk is NULL. Is this the correct way to check the
per-session
ECN capability ? Why is skb->sk NULL ?

Thanks,
Ravi

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Saturday, July 08, 2006 1:32 PM
To: mchan@broadcom.com
Cc: ravinandan.arakali@neterion.com; herbert@gondor.apana.org.au;
netdev@vger.kernel.org
Subject: Re: [PATCH]NET: Add ECN support for TSO


From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 7 Jul 2006 18:01:34 -0700

> However, Large Receive Offload will be a different story.  If
> packets are accumulated in the hardware and presented to the stack
> as one large packet, the stack will not be able to calculate the
> cumulative NS correctly.  Unless the hardware calculates the partial
> NS over the LRO packet and puts it in the SKB when handing over the
> packet.

This is correct, LRO hardware would need to do something to make sure
the nonce parity works out.

