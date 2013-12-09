From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Sun, 08 Dec 2013 19:13:40 -0800
Message-ID: <1386558820.30495.313.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
	 <1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPshTCiv1HxL9pRg3vp7pAOtdOOKoMVRQ4w8acq3aMga07NRig@mail.gmail.com>
	 <1386558263.30495.311.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131209030830.GA30565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:65462 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760229Ab3LIDNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:13:42 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so4353138pdi.38
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 19:13:42 -0800 (PST)
In-Reply-To: <20131209030830.GA30565@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 11:08 +0800, Herbert Xu wrote:
> On Sun, Dec 08, 2013 at 07:04:23PM -0800, Eric Dumazet wrote:
> > On Mon, 2013-12-09 at 10:48 +0800, Jerry Chu wrote:
> > 
> > > Not sure why ingress qdisc - it seems that qdisc_pkt_len_init() is only called
> > > by the egress path (__dev_xmit_skb())
> > > .
> > 
> > Yeah, Qdisc was meant to be used for egress.
> > 
> > Then to get qdisc for ingress, we use IFB to reinject packets through
> > the qdisc layer.
> 
> I don't think anything outside of GRO should be using the fields set
> by GRO.  If they were doing it implicitly before they should be
> fixed.  After all, they would be broken by something as simple
> as turning GRO off through ethtool, no?

Thats not what I said.

Please read 1def9238d4aa2146924994aa4b7dc861f03b9362 changelog
for details.

If GRO is off, of course qdisc_pkt_len_init() has no problem.
