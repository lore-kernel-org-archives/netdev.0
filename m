From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 9 Nov 2010 15:57:16 -0500
Message-ID: <20101109205716.GB9990@hmsreliant.think-freely.org>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
 <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
 <1289325753.2774.20.camel@edumazet-laptop>
 <20101109183820.GA8069@hmsreliant.think-freely.org>
 <1289330438.2774.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, zenczykowski@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60447 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab0KIU72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:59:28 -0500
Content-Disposition: inline
In-Reply-To: <1289330438.2774.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 08:20:38PM +0100, Eric Dumazet wrote:
> Le mardi 09 novembre 2010 =E0 13:38 -0500, Neil Horman a =E9crit :
> > On Tue, Nov 09, 2010 at 07:02:32PM +0100, Eric Dumazet wrote:
> > > Le mardi 09 novembre 2010 =E0 12:46 -0500, nhorman@tuxdriver.com =
a =E9crit :
> > ic char **alloc_pg_vec(struct tpacket_req *req, int order)
> > > > +static struct pgv *alloc_pg_vec(struct tpacket_req *req, int o=
rder)
> > > >  {
> > > >  	unsigned int block_nr =3D req->tp_block_nr;
> > > > -	char **pg_vec;
> > > > +	struct pgv *pg_vec;
> > > >  	int i;
> > > > =20
> > > > -	pg_vec =3D kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
> > > > +	pg_vec =3D kzalloc(block_nr * sizeof(struct pgv), GFP_KERNEL)=
;
> > >=20
> > > While we are at it, we could check block_nr being a sane value he=
re ;)
> > >=20
> > This is true.  What do you think a reasonable sane value is?  libpc=
ap seems to
> > limit itself to 32 order 5 entries in the ring, but that seems a bi=
t arbitrary.
> > Perhaps we could check and limit allocations to being no more than =
order 8
> > (1Mb), and a total allocation of no more than perhaps max(32Mb, 1% =
of all ram)?
> > Just throwing it out there, open to any suggestions here
>=20
> I was refering to a malicious/buggy program giving a big tp_block_nr =
so
> that (block_nr * sizeof(struct pgv)) overflows the u32
>=20
> One way to deal with that is to use
>=20
> 	kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);
>=20
> I am not sure consistency checks done in packet_set_ring() are enough=
 to
> properly detect such errors.
Ah, I get you, ok.  Yeah, I'll respin this with that taken into account=
=2E
Thanks!
Neil

>=20
>=20
>=20
>=20
>=20
>=20
