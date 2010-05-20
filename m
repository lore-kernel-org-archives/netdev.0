From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 07:36:19 +0200
Message-ID: <1274333779.2658.43.camel@edumazet-laptop>
References: <4BF4517F.1010206@athenacr.com>
	 <20100519.195533.22536631.davem@davemloft.net>
	 <20100520025741.GA6129@gondor.apana.org.au>
	 <20100519.200522.140743640.davem@davemloft.net>
	 <20100520033446.GA6434@gondor.apana.org.au>
	 <1274332507.2658.31.camel@edumazet-laptop>
	 <20100520052059.GC7443@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58461 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab0ETFg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:36:26 -0400
Received: by wyg36 with SMTP id 36so1031964wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 22:36:24 -0700 (PDT)
In-Reply-To: <20100520052059.GC7443@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 15:20 +1000, Herbert Xu a =C3=A9crit :
> On Thu, May 20, 2010 at 07:15:07AM +0200, Eric Dumazet wrote:
> >=20
> > I find this very biased, sorry.
> >=20
> > In fact, fd passing is just fine today, if we consider that we clas=
sify
> > packets using the identity of the process *using* the fd, not the o=
ne
> > that *created* it.
> >=20
> > Now your patch changes this, to the reverse, and you justify the ca=
ching
> > effect on socket. Sorry, this must be too convoluted for me.
>=20
> I'm sorry you find this convoluted, but using the sending process's
> classid is inherently broken.
>=20
> Here is why: consider a TCP socket shared by two processes with
> different classids both writing data to it.  Now suppose further
> that each writes just one byte, which is then coalesced into a
> single skb.
>=20
> Whose classid should we use on the resulting skb?

I am ok with any kind of clarification, if its really documented as
such, not as indirect effects of changes.

Right now, I am not sure classification is performed by the current
process/cpu. Our queue handling can process packets queued by other cpu=
s
while we own the queue (__QDISC_STATE_RUNNING,) anyway.



