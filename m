From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: fix length computation in rt_check_expire()
Date: Wed, 20 May 2009 06:27:54 -0400
Message-ID: <20090520102754.GA25492@hmsreliant.think-freely.org>
References: <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com> <20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39797 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119AbZETK2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 06:28:25 -0400
Content-Disposition: inline
In-Reply-To: <4A138CFE.5070901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 06:54:22AM +0200, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Tue, 19 May 2009 15:24:50 -0400
> >=20
> >>> Moving whole group in front would defeat the purpose of move, act=
ually,
> >>> since rank in chain is used to decay the timeout in garbage colle=
ctor.
> >>> (search for tmo >>=3D 1; )
> >>>
> >> Argh, so the list is implicitly ordered by expiration time.  That
> >> really defeats the entire purpose of doing grouping in the ilst at
> >> all.  If thats the case, then I agree, its probably better to to
> >> take the additional visitation hit in in check_expire above than t=
o
> >> try and preserve ordering.
> >=20
> > Yes, this seems best.
> >=20
> > I was worried that somehow the ordering also influences lookups,
> > because the TOS bits don't go into the hash so I worried that it wo=
uld
> > be important that explicit TOS values appear before wildcard ones.
> > But it doesn't appear that this is an issue, we don't have wildcard
> > TOSs in the rtable entries, they are always explicit.
> >=20
> > So I would like to see an explicit final patch from Eric so we can =
get
> > this fixed now.
> >=20
>=20
> I would like to split patches because we have two bugs indeed, and
> I prefer to get attention for both problems, I dont remember Neil ack=
nowledged
> the length computation problem.
>=20
> First and small patch, candidate for net-2.6 and stable (for 2.6.29) =
:
>=20
> Thank you
>=20
> [PATCH] net: fix length computation in rt_check_expire()
>=20
> rt_check_expire() computes average and standard deviation of chain le=
ngths,
> but not correclty reset length to 0 at beginning of each chain.
> This probably gives overflows for sum2 (and sum) on loaded machines i=
nstead=20
> of meaningful results.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>

>=20
