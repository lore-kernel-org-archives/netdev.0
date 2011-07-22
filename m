From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Thu, 21 Jul 2011 17:18:09 -0700 (PDT)
Message-ID: <20110721.171809.2276771570007039309.davem@davemloft.net>
References: <1311101870.3113.6.camel@edumazet-laptop>
	<20110719.115929.106510307852361614.davem@davemloft.net>
	<1311139774.3113.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab1GVASU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 20:18:20 -0400
In-Reply-To: <1311139774.3113.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jul 2011 07:29:34 +0200

> Le mardi 19 juillet 2011 =E0 11:59 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 19 Jul 2011 20:57:50 +0200
>>=20
>> > Le mardi 19 juillet 2011 =E0 20:20 +0200, Eric Dumazet a =E9crit :
>> >> Le mardi 19 juillet 2011 =E0 10:37 -0700, David Miller a =E9crit =
:
>> >> > From: Eric Dumazet <eric.dumazet@gmail.com>
>> >> > Date: Tue, 19 Jul 2011 19:23:49 +0200
>> >> >=20
>> >> > > Maybe you can find the bug before me ?
>> >> >=20
>> >> > I think when we add the route we cow the metrics almost immedia=
tely.
>> >> > The daddr is, unfortunately, fully prefixed at that point.
>> >>=20
>> >> Yes, we shall provide a second ip6_rt_copy() argument, with the
>> >> destination address.
>> >>=20
>> >=20
>> > Hmm, or maybe just change the dst_copy_metrics(&rt->dst, &ort->dst=
);
>> > call done from ip6_rt_copy(), to avoid doing the COW if not really
>> > needed ?
>>=20
>> This is ok if it handles the case where ort's metrics point to
>> writable inetpeer memory.
>=20
> OK but if ort's metrics are writeable we must perform the dst_copy_me=
trics()
> and therefore fill rt6i_dst before ?

If it's writable, then there are no problems.

Oh actually, I see what you mean.  This is a mess.

I'll try to think about this some more and look at your most
recent patches.
