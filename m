From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary
	address creation
Date: Tue, 1 Apr 2008 23:56:57 +0200
Message-ID: <20080401215657.GP475@pirzuine>
References: <patchbomb.1206305168@pirzuine> <ec551b4a5bb25cda00ff.1206305172@pirzuine> <20080328.120401.89511262.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:45925 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYDAV5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 17:57:01 -0400
Content-Disposition: inline
In-Reply-To: <20080328.120401.89511262.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 12:04:01PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <ec551b4a5bb25cda00ff.1206305172@pirzuine> (at Sun, 23 Mar=
 2008 21:46:12 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org>=
 says:
>=20
> > IPv6: fix lifetime calculation on temporary address creation
[snip]
> > +	now =3D jiffies;
> > +	elapsed =3D (now - ifp->tstamp) / HZ;
> > +	if (elapsed >=3D ifp->valid_lft)
> > +		tmp_valid_lft =3D 0;
> > +	else
> > +		tmp_valid_lft =3D min_t(__u32,
> > +				      ifp->valid_lft - elapsed,
> > +				      idev->cnf.temp_valid_lft);
> > +	if (elapsed >=3D ifp->prefered_lft)
> > +		tmp_prefered_lft =3D 0;
> > +	else
> > +		tmp_prefered_lft =3D min_t(__u32,
> > +					 ifp->prefered_lft - elapsed,
> > +					 idev->cnf.temp_prefered_lft - desync_factor / HZ);
>=20
> Basically I agree, but it is possible to expire the temporary
> address AFTER public address, which is not good.  Please fix this.

do you mean because of the rounding of 'elapsed' ? otherwise I don't se=
e
what the problem is, sorry.

regards,

Benoit

--=20
:wq
