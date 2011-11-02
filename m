From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fix NULL dereference in x25_recvmsg
Date: Wed, 02 Nov 2011 03:21:28 +0100
Message-ID: <1320200488.4728.29.camel@edumazet-laptop>
References: <20111102015315.GA6569@redhat.com>
	 <1320199845.4728.23.camel@edumazet-laptop>
	 <20111102021525.GA8512@redhat.com>
	 <1320200358.4728.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Matthew Daley <mattjd@gmail.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65107 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217Ab1KBCVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 22:21:35 -0400
Received: by wyh15 with SMTP id 15so1022998wyh.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 19:21:33 -0700 (PDT)
In-Reply-To: <1320200358.4728.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 03:19 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mardi 01 novembre 2011 =C3=A0 22:15 -0400, Dave Jones a =C3=A9crit=
 :
> > On Wed, Nov 02, 2011 at 03:10:45AM +0100, Eric Dumazet wrote:
> >  > Le mardi 01 novembre 2011 =C3=A0 21:53 -0400, Dave Jones a =C3=A9=
crit :
> >  > > commit cb101ed2 in 3.0 introduced a bug in x25_recvmsg()
> >  > > When passed bogus junk from userspace, x25->neighbour can be N=
ULL,
> >  > > as shown in this oops..
> >  > >=20
> >  >=20
> >  > Your patch seems fine but :
> >  >=20
> >  > Are you sure this bug is not present on previous kernels ?
> >  >=20
> >  > It seems we had prior to this commit :
> >  >=20
> >  > skb_pull(skb, x25->neighbour->extended ?
> >  > 	X25_EXT_MIN_LEN : X25_STD_MIN_LEN);
> >=20
> > It might have been possible with a specifically crafted set of argu=
ments.
> >=20
> > It never showed up in testing before now, probably because we were
> > returning from the function before we got to that skb_pull
> > via all the other tests that get performed.
> >=20
>=20
> neighbour is not an x25_recvmsg() argument, but related to x25 socket
> state.
>=20
> Maybe your tests dont try to use x25_recvmsg() while socket has no
> neighbour...
>=20
> This bug was there before the cb101ed2 commit.
>=20

Ah ok, I see now, we exited early because of=20

if (sk->sk_state !=3D TCP_ESTABLISHED)
	goto out;

So yes, commit cb101ed2 is the bug origin, sorry for the noise.
