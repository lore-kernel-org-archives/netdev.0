From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] atm: expose ATM device index in sysfs
Date: Thu, 26 May 2011 13:35:58 -0500
Message-ID: <1306434959.3151.39.camel@dcbw.foobar.com>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
	 <1306432509.2543.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753523Ab1EZSeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 14:34:36 -0400
In-Reply-To: <1306432509.2543.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-26 at 19:55 +0200, Eric Dumazet wrote:
> Le jeudi 26 mai 2011 =C3=A0 12:47 -0500, Dan Williams a =C3=A9crit :
> > It's current exposed only through /proc which besides requiring
> > screen-scraping doesn't allow userspace to distinguish between two
> > identical ATM adapters with different ATM indexes.  The ATM device =
index
> > is required when using PPPoATM on a system with multiple ATM adapte=
rs.
> >=20
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > ---
> >=20
> > PS: -> stable too since it's a minimal change with no backwards
> > incompatibility and I'd like to rely on this attribute in NetworkMa=
nager
> >=20
> > diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
> > index f7fa67c..e5edbde 100644
> > --- a/net/atm/atm_sysfs.c
> > +++ b/net/atm/atm_sysfs.c
> > @@ -59,6 +59,16 @@ static ssize_t show_atmaddress(struct device *cd=
ev,
> >  	return pos - buf;
> >  }
> > =20
> > +static ssize_t show_atmindex(struct device *cdev,
> > +			     struct device_attribute *attr, char *buf)
> > +{
> > +	char *pos =3D buf;
> > +	struct atm_dev *adev =3D to_atm_dev(cdev);
> > +
> > +	pos +=3D sprintf(pos, "%d\n", adev->number);
> > +	return pos - buf;
> > +}
> > +
>=20
> What about :
>=20
> {
> 	struct atm_dev *adev =3D to_atm_dev(cdev);
>=20
> 	return sprintf(buf, "%d\n", adev->number);
> }

Sure, will send v2.

Dan

