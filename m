From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Query on a lockdep issue in neigh_lookup
Date: Wed, 14 Sep 2011 01:59:08 +0200
Message-ID: <1315958348.2565.22.camel@edumazet-laptop>
References: <CAByGWUHkt=6AjW_GFsGd1EnbMC=pjhtxRu8ez0sw6rZNvA_nxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Murali raja Muniraju <murali.rajam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33576 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab1IMX7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 19:59:21 -0400
Received: by wyh22 with SMTP id 22so1101991wyh.19
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 16:59:20 -0700 (PDT)
In-Reply-To: <CAByGWUHkt=6AjW_GFsGd1EnbMC=pjhtxRu8ez0sw6rZNvA_nxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 septembre 2011 =C3=A0 16:11 -0700, Murali raja Muniraju a =C3=
=A9crit :
> Hi,
>    I see a potential deadlock situation on the kernel 2.6.34. Has thi=
s
> been fixed in the later version of the kernel.
>=20
> I see that one after holding the neigh_lookup, one can acquire the
> lock for rt_hash_locks
>=20
> But there is a situation while freed skb's in dst_release while
> holding the rt_hash_locks, neigh_lookup can be called which tries to
> acquire its lock.
>=20
> This seems to be a deadlock candidate.
>=20
> Thanks,
> Murali
>=20
> Below if the scenario found by lockdep on a debug kernel during the
> kernel bootup.
>=20

All this code changed in 2.6.37 with commit
d6bf781712a1d25cc8987036b3a48535b331eb91
(net neigh: RCU conversion of neigh hash table)
