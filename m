From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Wed, 20 Jul 2011 07:29:34 +0200
Message-ID: <1311139774.3113.86.camel@edumazet-laptop>
References: <20110719.103724.1461298517132188126.davem@davemloft.net>
	 <1311099638.3113.2.camel@edumazet-laptop>
	 <1311101870.3113.6.camel@edumazet-laptop>
	 <20110719.115929.106510307852361614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40687 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab1GTF3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 01:29:40 -0400
Received: by wwe5 with SMTP id 5so4843502wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 22:29:39 -0700 (PDT)
In-Reply-To: <20110719.115929.106510307852361614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 11:59 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 19 Jul 2011 20:57:50 +0200
>=20
> > Le mardi 19 juillet 2011 =C3=A0 20:20 +0200, Eric Dumazet a =C3=A9c=
rit :
> >> Le mardi 19 juillet 2011 =C3=A0 10:37 -0700, David Miller a =C3=A9=
crit :
> >> > From: Eric Dumazet <eric.dumazet@gmail.com>
> >> > Date: Tue, 19 Jul 2011 19:23:49 +0200
> >> >=20
> >> > > Maybe you can find the bug before me ?
> >> >=20
> >> > I think when we add the route we cow the metrics almost immediat=
ely.
> >> > The daddr is, unfortunately, fully prefixed at that point.
> >>=20
> >> Yes, we shall provide a second ip6_rt_copy() argument, with the
> >> destination address.
> >>=20
> >=20
> > Hmm, or maybe just change the dst_copy_metrics(&rt->dst, &ort->dst)=
;
> > call done from ip6_rt_copy(), to avoid doing the COW if not really
> > needed ?
>=20
> This is ok if it handles the case where ort's metrics point to
> writable inetpeer memory.

OK but if ort's metrics are writeable we must perform the dst_copy_metr=
ics()
and therefore fill rt6i_dst before ?

My first patch had an issue in rt6_alloc_cow(), line 710, where=20
ipv6_addr_equal(&rt->rt6i_dst.addr, daddr) becomes always true.

I guess I can replace it by ipv6_addr_equal(&ort->rt6i_dst.addr, daddr)



