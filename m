From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Mon, 9 Dec 2013 11:08:30 +0800
Message-ID: <20131209030830.GA30565@gondor.apana.org.au>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
 <1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAPshTCiv1HxL9pRg3vp7pAOtdOOKoMVRQ4w8acq3aMga07NRig@mail.gmail.com>
 <1386558263.30495.311.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:44150 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3LIDIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:08:41 -0500
Content-Disposition: inline
In-Reply-To: <1386558263.30495.311.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 08, 2013 at 07:04:23PM -0800, Eric Dumazet wrote:
> On Mon, 2013-12-09 at 10:48 +0800, Jerry Chu wrote:
> 
> > Not sure why ingress qdisc - it seems that qdisc_pkt_len_init() is only called
> > by the egress path (__dev_xmit_skb())
> > .
> 
> Yeah, Qdisc was meant to be used for egress.
> 
> Then to get qdisc for ingress, we use IFB to reinject packets through
> the qdisc layer.

I don't think anything outside of GRO should be using the fields set
by GRO.  If they were doing it implicitly before they should be
fixed.  After all, they would be broken by something as simple
as turning GRO off through ethtool, no?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
