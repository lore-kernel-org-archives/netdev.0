From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 6 Apr 2011 14:40:59 -0400
Message-ID: <20110406184059.GC6825@hmsreliant.think-freely.org>
References: <1302113253.3209.126.camel@edumazet-laptop>
 <20110406.111712.226782643.davem@davemloft.net>
 <1302114188.3209.128.camel@edumazet-laptop>
 <20110406.112712.71110955.davem@davemloft.net>
 <1302115064.3209.132.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59720 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756399Ab1DFSlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:41:03 -0400
Content-Disposition: inline
In-Reply-To: <1302115064.3209.132.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 08:37:44PM +0200, Eric Dumazet wrote:
> Le mercredi 06 avril 2011 =E0 11:27 -0700, David Miller a =E9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 06 Apr 2011 20:23:08 +0200
> >=20
> > > Le mercredi 06 avril 2011 =E0 11:17 -0700, David Miller a =E9crit=
 :
> > >> From: Eric Dumazet <eric.dumazet@gmail.com>
> > >> Date: Wed, 06 Apr 2011 20:07:33 +0200
> > >>=20
> > >> > This is why we used on ipv4 :
> > >> >=20
> > >> > if (inet_sk(sk)->inet_daddr)
> > >> > 	sock_rps_save_rxhash(sk, skb->rxhash);
> > >> >=20
> > >> >=20
> > >> > Only arm RFS on UDP if socket is bound to a given remote peer.
> > >>=20
> > >> Agreed, Neil please make this change to your ipv6 code.
> > >=20
> > > BTW, do you guys know if NFS is using RFS right now (if TCP trans=
port is
> > > used) ?
> >=20
> > It ought to be.  Are you specifically concerned that it might be
> > missing the rxhash setting calls because of the APIs it uses to
> > do socket I/O?
> >=20
> > The SunRPC layer is a major user of tcp_read_sock(), for example.
> >=20
> > But the packet processing will be done via the normal means,
> > therefore we'll hit tcp_v4_do_rcv() and therefore save the
> > rxhash.
>=20
> Hmm, are multiple tcp sessions used between NFS client and server (On=
e
> per cpu on client ?)
nope, its all nominally done per mount (i.e. all applications writing t=
o a given
mount point will share the same socket).
Neil

>=20
>=20
>=20
>=20
