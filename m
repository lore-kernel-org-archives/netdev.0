From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: GTSM and TCP accept problem
Date: Wed, 18 Aug 2010 14:39:13 -0700
Message-ID: <20100818143913.1478acea@nehalam>
References: <20100814214634.24a87715@s6510>
	<1281951825.2524.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42101 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751482Ab0HRVjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:39:16 -0400
In-Reply-To: <1281951825.2524.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Aug 2010 11:43:45 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le samedi 14 ao=FBt 2010 =E0 21:46 -0400, Stephen Hemminger a =E9crit=
 :
> > The implementation of Generalized TTL Security has a problem
> > on the TCP accept side. Since there can be different number of
> > hops for each peer, the listener ends up doing
> >=20
> >    socket
> >    bind
> >    set TTL to 255
> >    listen
> >    while (nfd =3D accept(peer)) {
> >      info =3D lookup(peer)
> >      set MINTTL to 255 - info->ttl_hops
> >=20
> >=20
> > The problem is that a rogue peer can still do three way
> > handshake causing the accept to succeed. But the rogue will
> > leave a stuck connection that will then have to timeout.
> >=20
> > The only ways I have come up to deal with this are:
> >    * have short timeout on initial data (recycle faster)
> >    * push peer;MINTTL table down into kernel (per socket)
> >    * have BGP do this through iptables which is a non-starter
> >      for a general application that needs to run on BSD, and
> >      would mess up existing firewall rules.
> >=20
> > Ideas welcome..
> > --
>=20
> Another idea would be to store the TTL of the SYN packet (or third
> packet) and let application read it after accept(), allowing it to
> reject the connection if it doesnt match expected TTL.

could be in tcp_info?
--=20
