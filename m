From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 09 Nov 2010 20:20:38 +0100
Message-ID: <1289330438.2774.25.camel@edumazet-laptop>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
	 <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
	 <1289325753.2774.20.camel@edumazet-laptop>
	 <20101109183820.GA8069@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, zenczykowski@gmail.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50136 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab0KITUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 14:20:46 -0500
Received: by wyb36 with SMTP id 36so5152468wyb.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 11:20:44 -0800 (PST)
In-Reply-To: <20101109183820.GA8069@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 13:38 -0500, Neil Horman a =C3=A9crit =
:
> On Tue, Nov 09, 2010 at 07:02:32PM +0100, Eric Dumazet wrote:
> > Le mardi 09 novembre 2010 =C3=A0 12:46 -0500, nhorman@tuxdriver.com=
 a =C3=A9crit :
> ic char **alloc_pg_vec(struct tpacket_req *req, int order)
> > > +static struct pgv *alloc_pg_vec(struct tpacket_req *req, int ord=
er)
> > >  {
> > >  	unsigned int block_nr =3D req->tp_block_nr;
> > > -	char **pg_vec;
> > > +	struct pgv *pg_vec;
> > >  	int i;
> > > =20
> > > -	pg_vec =3D kzalloc(block_nr * sizeof(char *), GFP_KERNEL);
> > > +	pg_vec =3D kzalloc(block_nr * sizeof(struct pgv), GFP_KERNEL);
> >=20
> > While we are at it, we could check block_nr being a sane value here=
 ;)
> >=20
> This is true.  What do you think a reasonable sane value is?  libpcap=
 seems to
> limit itself to 32 order 5 entries in the ring, but that seems a bit =
arbitrary.
> Perhaps we could check and limit allocations to being no more than or=
der 8
> (1Mb), and a total allocation of no more than perhaps max(32Mb, 1% of=
 all ram)?
> Just throwing it out there, open to any suggestions here

I was refering to a malicious/buggy program giving a big tp_block_nr so
that (block_nr * sizeof(struct pgv)) overflows the u32

One way to deal with that is to use

	kcalloc(block_nr, sizeof(struct pgv), GFP_KERNEL);

I am not sure consistency checks done in packet_set_ring() are enough t=
o
properly detect such errors.




