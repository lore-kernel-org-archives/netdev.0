From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 13:42:07 +1000
Message-ID: <20100520034207.GA6707@gondor.apana.org.au>
References: <4BF4517F.1010206@athenacr.com> <20100519.195533.22536631.davem@davemloft.net> <20100520025741.GA6129@gondor.apana.org.au> <20100519.200522.140743640.davem@davemloft.net> <20100520033446.GA6434@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35227 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752890Ab0ETDmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:42:18 -0400
Content-Disposition: inline
In-Reply-To: <20100520033446.GA6434@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 01:34:46PM +1000, Herbert Xu wrote:
>
> cls_cgroup: Store classid in struct sock
> 
> Up until now cls_cgroup has relied on fetching the classid out of
> the current executing thread.  This runs into trouble when a packet
> processing is delayed in which case it may execute out of another
> thread's context.

Oh please add this bit that I forgot about:

This also addresses the case where TCP transmits a queued packet
in response to an inbound ACK.  Currently this isn't classified
at all as we would be in softirq context.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
