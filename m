From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 18 Aug 2010 15:28:39 +0200
Message-ID: <1282138119.2194.75.camel@edumazet-laptop>
References: <1282136626.2194.68.camel@edumazet-laptop>
	 <E1OliUz-0006py-00.xeb-mail-ru@f121.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55281 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab0HRN2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:28:48 -0400
Received: by wyb32 with SMTP id 32so784577wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:28:46 -0700 (PDT)
In-Reply-To: <E1OliUz-0006py-00.xeb-mail-ru@f121.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 17:16 +0400, Dmitry Kozlov a =C3=A9=
crit :
> > Hmm. You left a synchronize_rcu() call in add_chan() but this is no=
t
> > necessary. Please remove it or explain why you think it is needed.
> >=20
> > synchronize_rcu(); in del_chan() is now fine, thanks.
> >=20
> >=20
> > You use a mutex for gre_proto_lock, but you dont need a mutex, plea=
se
> > use a spinlock like I suggested. I would have said 'use a mutex' if=
 if
> > was needed, you can trust me.
>=20
> ok
>=20
> > A mutex is needed if you can sleep while holding the lock, this is =
not
> > the case here. A spinlock is faster and reduces to no-op on !SMP
>=20
> then i have to replace mutex on spinlock in pptp module too ?
>=20

Yes indeed, you can use a spinlock there too ;)

> > Also, please remove the synchronize_rcu() call from gre_add_protoco=
l() :
> > It is not needed at all, like in add_chan().
> >=20
> > (You dont have to wait for a RCU grace period when adding something=
,
> > only when removing from a data structure)
>=20
> ok, seems like i don't fully understand rcu mechanism...
>=20

no problem, I dont fully understand rcu myself you know :)

> Thanks for reply.
>=20


