From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Tue, 5 Mar 2013 03:37:52 +0000
Message-ID: <1362454672.3768.383.camel@deadeye.wl.decadent.org.uk>
References: <512F1534.9020404@asianux.com>
	   <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
	   <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>
	  <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>
	  <51355936.3060307@asianux.com>
	 <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>
	 <51356735.4020405@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	<venkat.x.venkatsubra@oracle.com>,
	David Miller <davem@davemloft.net>, <rds-devel@oss.oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8146 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933039Ab3CEDiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 22:38:09 -0500
In-Reply-To: <51356735.4020405@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 11:32 +0800, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 11:16, Ben Hutchings =E5=
=86=99=E9=81=93:
> > I think it is wrong, and the code should be changed to do either:
> >=20
> > 1. Zero-initialise the whole of the name, then use strlcpy().
> > 2. Keep using strncpy(), and also set the last byte of name to 0.
> >=20
>=20
>   I think what I have done is just like your choice "2."
>   for me, I think they are equal:
>=20
> -		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> +		strlcpy(ctr.name, names[i], sizeof(ctr.name));
>=20
>=20
> 		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> + 		ctr.name[sizeof(ctr.name) - 1] =3D '\0';

They are not.  strncpy() pads with zeroes to the end of the given buffe=
r
whereas strlcpy() adds only a single zero byte (and truncates if
necessary to fit the zero byte).

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
