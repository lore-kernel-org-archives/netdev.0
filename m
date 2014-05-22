From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Thu, 22 May 2014 14:47:54 -0300
Message-ID: <20140522174754.GC1785@arch.cereza>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140505144702.GB12693@arch.cereza>
 <1400638291.17377.73.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, cmetcalf@tilera.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Simon Guinot <sguinot@lacie.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:48106 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750835AbaEVRsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 13:48:33 -0400
Content-Disposition: inline
In-Reply-To: <1400638291.17377.73.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 May 03:11 AM, Ben Hutchings wrote:
> On Mon, 2014-05-05 at 11:47 -0300, Ezequiel Garcia wrote:
> > Hi all,
> >=20
> > On 10 Apr 07:58 PM, Ezequiel Garcia wrote:
> > [..]
> > > +
> > > +	/* Calculate expected number of TX descriptors */
> > > +	desc_count =3D skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)-=
>nr_frags;
> > > +	if ((txq->count + desc_count) >=3D txq->size)
> > > +		return 0;
> > > +
> >=20
> > Is this calculus correct? Does it give the accurate number of neede=
d
> > descriptors or is it an approximation?
> >=20
>=20
> There are (at least) three potential bugs you need to avoid:
>=20
> 1. You must not underestimate the number of descriptors required here=
,
> otherwise the ring may overflow.  Hopefully that's obvious.

Yes, fully understood.

> 2. You must ensure that the worst case number of descriptors does
> actually fit in the ring, and will probably need to set
> net_dev->gso_max_segs accordingly.  Eric pointed that out already.

Yeah, I still need to take a deep look at the commit pointed out by Eri=
c.

> 3. If you stop the queue because an skb doesn't fit, you should not w=
ake
> it before there is enough space.
>=20
> A simple way to do this is:
>=20
> - Set a maximum number of segments to support (for sfc, I reckoned th=
at
> 100 was enough)
> - Calculate the maximum number of descriptors that could be needed fo=
r
> that number of segments
> - Stop the queue when the free space in the ring is less than that
> maximum
> - Wake the queue when the free space reaches a threshold somewhere
> between that maximum and completely free
>=20
> It may make more sense to work backward from the ring size to maximum
> number of segments.
>=20

Hm, this seems a good suggestion. I'm wondering if this can be added to
the generic code. Although this is likely each driver's responsability.

BTW, have you seen the proposal for the generic TSO API?

http://permalink.gmane.org/gmane.linux.network/316852

Any comments about it would be much appreciated, as we'd really like
to see TSO implemented on our drivers.

Thanks,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
