From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Sat, 30 Jan 2010 07:58:24 +0100
Message-ID: <1264834704.2919.3.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>  <1264816777.2793.510.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:47764 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab0A3G62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 01:58:28 -0500
In-Reply-To: <1264816777.2793.510.camel@tonnant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 janvier 2010 =C3=A0 20:59 -0500, Jon Masters a =C3=A9cri=
t :
> On Fri, 2010-01-29 at 20:57 -0500, Jon Masters wrote:
>=20
> > Ah so I should have realized before but I wasn't looking at valid v=
alues
> > for the range of the hashtable yet, nf_conntrack_htable_size is get=
ting
> > wildly out of whack. It goes from:
> >=20
> > (gdb) print nf_conntrack_hash_rnd
> > $1 =3D 2688505299
> > (gdb) print nf_conntrack_htable_size
> > $2 =3D 16384
> >=20
> > nf_conntrack_events: 1
> > nf_conntrack_max: 65536
> >=20
> > Shortly after booting, before being NULLed shortly after starting s=
ome
> > virtual machines (the hash isn't reset, whereas it is recomputed if=
 the
> > hashtable is re-initialized after an intentional resizing operation=
):
>=20
> I mean the *seed* isn't changed, so I don't think it was resized
> intentionally. I wonder where else htable_size is fiddled with.
>=20
> Jon.
>=20
>=20

This rings a bell here, since another crash analysis on another problem
suggested to me a potential problem with read_mostly and modules, but I
had no time to confirm the thing yet.

Could you try changing


net/netfilter/nf_conntrack_core.c:57:unsigned int nf_conntrack_htable_s=
ize __read_mostly;
to
net/netfilter/nf_conntrack_core.c:57:unsigned int nf_conntrack_htable_s=
ize ;



