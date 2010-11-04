From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Freeing alive fib_info caused by ebc0ffae5
Date: Thu, 04 Nov 2010 11:46:46 +0100
Message-ID: <1288867606.2659.72.camel@edumazet-laptop>
References: <1288866186.30549.10.camel@concordia>
	 <1288866626.2659.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53148 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab0KDKqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 06:46:50 -0400
Received: by wyf28 with SMTP id 28so1760474wyf.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 03:46:49 -0700 (PDT)
In-Reply-To: <1288866626.2659.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 novembre 2010 =C3=A0 11:30 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 04 novembre 2010 =C3=A0 21:23 +1100, Michael Ellerman a =C3=A9=
crit :
> > Hi all,
> >=20
> > I'm running Linus' latest or thereabouts (ff8b16d), and I'm seeing
> > "Freeing alive fib_info" messages, from free_fib_info().
> >=20
> > Actually I only get one per boot, when network interfaces come up.
> > Seemingly related I am getting refcount problems when I shutdown, i=
e.
> > unregister_netdevice() sees a usage count of 1, which never decreme=
nts.
> >=20
> > Bisect says it's ebc0ffae5 which causes the problem, or makes it ap=
pear.
> >=20
> >     fib: RCU conversion of fib_lookup()
> >    =20
> >     fib_lookup() converted to be called in RCU protected context, n=
o
> >     reference taken and released on a contended cache line (fib_cln=
tref)
> >    =20
> >=20
> > Is this a bug in that commit, or a driver bug exposed?
>=20
> Hi Michael, thanks for the report (and painful bisection I guess)
>=20
> Thats hard to say... Is it reproductable on my machine ?

You could ask a stack trace eventually, this might help to spot the bug=
=2E

Thanks

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3e0da3e..8039db0 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -159,6 +159,7 @@ void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead =3D=3D 0) {
 		pr_warning("Freeing alive fib_info %p\n", fi);
+		WARN_ON_ONCE(1);
 		return;
 	}
 	change_nexthops(fi) {



