From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 16:33:56 +0200
Message-ID: <1319034836.8416.30.camel@edumazet-laptop>
References: <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
	 <1319030740.8416.14.camel@edumazet-laptop>
	 <1319031348.1286.4.camel@jlt3.sipsolutions.net>
	 <1319031856.8416.19.camel@edumazet-laptop>
	 <1319032638.1286.7.camel@jlt3.sipsolutions.net>
	 <1319033305.8416.29.camel@edumazet-laptop>
	 <1319034248.1286.8.camel@jlt3.sipsolutions.net>
	 <20111019142750.GB15253@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48400 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab1JSOeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:34:02 -0400
Received: by bkbzt19 with SMTP id zt19so2193144bkb.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 07:34:01 -0700 (PDT)
In-Reply-To: <20111019142750.GB15253@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 16:27 +0200, Richard Cochran a =C3=A9=
crit :
> On Wed, Oct 19, 2011 at 04:24:08PM +0200, Johannes Berg wrote:
> > On Wed, 2011-10-19 at 16:08 +0200, Eric Dumazet wrote:
> >=20
> > > > Anyway, I guess you agree that the patches as-is aren't actuall=
y the
> > > > right solution since we can't sock_hold() a TX skb socket refer=
ence?
> > >=20
> > > Yes, the sock_hold() could be changed by an atomic_inc_not_zero()
> > >=20
> > > What about doing this ?
> >=20
> > >  		if (likely(phydev->drv->txtstamp)) {
> > > +			if (!atomic_inc_not_zero(&sk->sk_refcnt))
> > > +				return;
> >=20
> > Yeah that seems like it works and just drops the timestamp in case =
we
> > don't still have a live socket, which is perfectly fine.
>=20
> Yes, I think it resolves any doubt. I will resubmit with this
> solution.
>=20

Thanks guys !
