From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Wed, 16 Nov 2011 08:30:50 +0200
Message-ID: <3443203.gVgdO3ogFg@hector>
References: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com> <2168215.tYVKKNoJjY@hector> <81C3A93C17462B4BBD7E272753C105791FB090B0B8@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.47]:57559 "EHLO mgw-sa01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486Ab1KPGal convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 01:30:41 -0500
Received: from hector.localnet (esdhcp034220.research.nokia.com [172.21.34.220])
	by mgw-sa01.nokia.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id pAG6UaVJ007907
	for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 08:30:36 +0200
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791FB090B0B8@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Lundi 14 Novembre 2011 11:36:12 ext Hemant-vilas RAMDASI a =E9crit :
 > > sockaddr_pn *spn) /* Phonet device ioctl requests */
> > >=20
> > >  #ifdef __KERNEL__
> > >  #define SIOCPNGAUTOCONF		(SIOCDEVPRIVATE + 0)
> > >=20
> > > +#define SIOPNPIPE_ENABLE	_IO(SIOCPNGAUTOCONF,   1)
> >=20
> > Does this even work? I am not an expert on this, but I would think =
that
> > device-private controls are routed to the network device, not the
> > socket. In
> > any case, it does not seem right.
>=20
> Yes, it works. The ioctl is routed to per-socket functions.

Even if it works, sockets are probably not supposed to use the device-p=
rivate=20
ioctl() range, are they?

And why is this inside __KERNEL__ ?

> > > @@ -994,6 +1068,17 @@ static int pep_getsockopt(struct sock *sk, =
int
> >=20
> > level,
> >=20
> > > int optname, return -EINVAL;
> > >=20
> > >  		break;
> > >=20
> > > +	case PNPIPE_ENABLE:
> > > +		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
> > > +			val =3D 1;
> > > +		else
> > > +			val =3D 0;
> > > +		break;
> >=20
> > Do you still need this read-only option?
>=20
> Yes.

Why and how?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
