From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Thu, 31 Mar 2011 16:47:52 +0200
Message-ID: <1301582872.3169.44.camel@edumazet-laptop>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net>
	 <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
	 <124481299095426@web67.yandex.ru>
	 <AANLkTik87dd0=CqcMOcwKN-Hx7W6KD7A36DUhGAzLddr@mail.gmail.com>
	 <AANLkTi=v_Ckn00N=b2R2pW7jb3BmyyWPSkeCYRxBW0CW@mail.gmail.com>
	 <586191301580222@web107.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61830 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757998Ab1CaOsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 10:48:01 -0400
In-Reply-To: <586191301580222@web107.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 31 mars 2011 =C3=A0 18:03 +0400, "Oleg A. Arkhangelsky" a =C3=A9=
crit :
>=20
> 26.03.2011, 16:44, "Changli Gao" <xiaosuo@gmail.com>:
> > On Thu, Mar 3, 2011 at 3:33 PM, Changli Gao <xiaosuo@gmail.com>; wr=
ote:
> >
> >>  Please try the patch attached and test if the problem is solved o=
r not. Thanks.
> >
> > Any feedback? Thanks.
> >
>=20
> Seems that patch is fine.
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D21512
>=20

I wonder if this is not hiding another bug.

Adding an RCU grace period might reduce the probability window.

By the time nf_conntrack_free(ct) is called, no other cpu/thread
could/should use ct, or ct->ext ?

Sure, another thread can find/pass_on ct in a lookup but should not use
it, since its refcount (ct_general.use) should be 0.

Patrick ?


