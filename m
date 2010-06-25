From: Michal Humpula <michal.humpula@hudrydum.cz>
Subject: Re: nonlocal_bind & IPv6
Date: Fri, 25 Jun 2010 21:10:08 +0200
Message-ID: <201006252110.08508.michal.humpula@hudrydum.cz>
References: <201006252043.45581.michal.humpula@hudrydum.cz> <30fe1fa984e52f4cca318e54f9d97a21@chewa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:38027 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932368Ab0FYTKL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 15:10:11 -0400
In-Reply-To: <30fe1fa984e52f4cca318e54f9d97a21@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, more detail example.=20

Let on each node be an apache (just for an example), and you configure =
VirtualHost for=20
specific IP. So when node A fails, keepalived move IP to the node B and=
 everything is=20
still running. No need for restart of apache or anything else. There is=
 a probably a=20
better solution, but I can't find anything more simple than the posted =
patch:)

On Friday 25 of June 2010 20:59:58 R=C3=A9mi Denis-Courmont wrote:
> On Fri, 25 Jun 2010 20:43:45 +0200, Michal Humpula
>=20
> <michal.humpula@hudrydum.cz> wrote:
> > I was just wondering, what's wrong with this?
>=20
> It's not in unified format :D
>=20
> > *** linux-2.6.34/net/ipv6/af_inet6.c    2010-05-16 23:17:36.0000000=
00
> > +0200
> > --- linux-2.6.34-hack/net/ipv6/af_inet6.c       2010-06-25
> > 19:50:19.000000000 +0200
> > ***************
> > *** 345,354 ****
> > --- 345,356 ----
> >=20
> >                         if (!(addr_type & IPV6_ADDR_MULTICAST)) {
> >                        =20
> >                                 if (!ipv6_chk_addr(net, &addr->sin6=
_addr,
> >                                =20
> >                                                    dev, 0)) {
> >=20
> > +           if (!sysctl_ip_nonlocal_bind) {
> >=20
> >                                         err =3D -EADDRNOTAVAIL;
> >                                         goto out_unlock;
> >            =20
> >             }
> >            =20
> >                                 }
> >=20
> > +                       }
> >=20
> >                         rcu_read_unlock();
> >                =20
> >                 }
> >        =20
> >         }
> >=20
> > Motivation: just want to balance one IPv6 address between two nodes=
 with
> > the help of keepalived the same way I do it with IPv4 without the n=
eed
> > of restarting the daemons binding on that IP.
>=20
> nonlocal_bind seems a bit 80's to me. Why don't you bind the daemon t=
o
> [::]? If it needs to know its own address, it can always use getsockn=
ame()
> for connected sockets and IPV6_PKTINFO ancillary data for datagram so=
ckets.
