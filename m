From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 20:42:10 +1000
Message-ID: <E1G7VDu-0006kn-00@gondolin.me.apana.org.au>
References: <1154340236.3642.11.camel@LINE>
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59152 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751508AbWGaKm3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:42:29 -0400
To: yjwei@nanjing-fnst.com (Wei Yongjun)
In-Reply-To: <1154340236.3642.11.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
>
> I also send the same mail several ago, and get no response. You
> patch is fine. But I think following code has no effect:
> 
> if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
> 
> It just let UDP datagrams with checksum error be added into  UDP receive
> queue, and then discard it. I think this can be used to capture a UDP

We normally postpone the checksum computation until the user does a
recv(2).  However, if there is a socket filter attached then we need
to verify the checksum right now because the socket filter will be
applied at the very next step.

So yes it does let UDP datagrams with checksum errors onto the UDP rcv
queue if there no socket filters attached, but this is intentional since 
we want to postpone the cost of checksum computation until the point when
we have to copy the data to user-space where it becomes much cheaper.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
