From: Clement LECIGNE <clement.lecigne@netasq.com>
Subject: Re: [PATCH] 8 bytes kernel memory disclosure in AppleTalk
	getsockname.
Date: Wed, 26 Aug 2009 14:39:31 +0200
Message-ID: <20090826123931.GA26429@clem1.netasq.com>
References: <20090826111247.GA79673@clem1.netasq.com> <4A952C2D.2010807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netasq.netasq.com ([213.30.137.178]:20755 "EHLO
	netasq.netasq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690AbZHZMk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:40:27 -0400
Content-Disposition: inline
In-Reply-To: <4A952C2D.2010807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 26, 2009 at 02:35:57PM +0200, Eric Dumazet wrote:
> Clement LECIGNE a =E9crit :
> > Hi,
> >=20
> > In function atalk_getname(), sockaddr_at is returned in userland wi=
thout
> > zero'ing the "char sat_zero[8]" field. This bug allows user to disp=
lay 8
> > bytes leaked from the kernel stack.
> >=20
> > Here is a patch that zero the whole sockaddr_at structure before
> > processing it. It should fix this bug.
> >=20
> > Signed-off-by: Cl=E9ment Lecigne <clement.lecigne@netasq.com>
> > --- linux/net/appletalk/ddp.c	2009-08-26 11:35:59.000000000 +0200
> > +++ linux/net/appletalk/ddp.c	2009-08-26 11:36:30.000000000 +0200
> > @@ -1241,6 +1241,8 @@ static int atalk_getname(struct socket *
> >  		if (atalk_autobind(sk) < 0)
> >  			return -ENOBUFS;
> > =20
> > +	memset(&sat, 0, sizeof(struct sockaddr_at));
> > +
> >  	*uaddr_len =3D sizeof(struct sockaddr_at);
> > =20
> >  	if (peer) {
> >=20
> Hi Clement
>=20
> Well, I submitted same patch some weeks ago and I just checked that
> it was already in Linus tree.
>=20
> author	Eric Dumazet <eric.dumazet@gmail.com>
> 	Thu, 6 Aug 2009 02:27:43 +0000 (02:27 +0000)
> committer	David S. Miller <davem@davemloft.net>
> 	Thu, 6 Aug 2009 20:08:45 +0000 (13:08 -0700)
> commit	3d392475c873c10c10d6d96b94d092a34ebd4791
>=20
> appletalk: fix atalk_getname() leak
>=20
> atalk_getname() can leak 8 bytes of kernel memory to user
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> Dont worry, it'll be included in upcoming 2.6.31 kernel,
> and backported to previous ones as well.

Hi Eric,

Oups, shame on me, I have not checked Linus tree before submitting the
patch.

Sorry,

--=20
Cl=E9ment LECIGNE,
-Only one remote hole in the default install, in more than 10 years!<br=
>
+Only two remote holes in the default install, in more than 10 years!<b=
r>

