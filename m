From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Tue, 5 Mar 2013 03:16:59 +0000
Message-ID: <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>
References: <512F1534.9020404@asianux.com>
	  <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
	  <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <51355936.3060307@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	<venkat.x.venkatsubra@oracle.com>,
	David Miller <davem@davemloft.net>, <rds-devel@oss.oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28538 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759287Ab3CEDRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 22:17:21 -0500
In-Reply-To: <51355936.3060307@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 10:32 +0800, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 02:34, Ben Hutchings =E5=
=86=99=E9=81=93:
> > On Mon, 2013-03-04 at 18:32 +0000, Ben Hutchings wrote:
> >> > On Thu, 2013-02-28 at 09:36 +0000, David Laight wrote:
> >>> > >=20
> >>> > > If the target buffer ends up being copied to userspace that
> >>> > > might lead to random kernel memory being leaked.
> >> >=20
> >> > Seems it is.  The last byte of 'name' is not currently initialis=
ed and
> >> > therefore is already leaked to userland.
> >> >=20
> >> > But it's OK because rds_info_copy() uses memcpy() not __copy_to_=
user(),
> >> > so SMAP will block this leak. :-)
> > Or not, as kmap() presumably evades that.
>=20
>  is this patch ok, or need improving ?

I think it is wrong, and the code should be changed to do either:

1. Zero-initialise the whole of the name, then use strlcpy().
2. Keep using strncpy(), and also set the last byte of name to 0.

> BTW:
>   excuse me, maybe my reply will be late during this week.
>   the reason:
>     my father had a serious heart disease, and is in hospital.
>     during these days, most of my time has to be in hospital.
>       (God Bless, and thank Jesus Christ, my father is safe, now).
>     within my company (Asianux), I also have something to do.

Best wishes to you both.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
