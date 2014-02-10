From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] dp83640: Get gpio and master/slave configuration from
 DT
Date: Mon, 10 Feb 2014 15:39:01 +0000
Message-ID: <20140210153901.GH29080@e106331-lin.cambridge.arm.com>
References: <1392037240-30913-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140210134237.GF29080@e106331-lin.cambridge.arm.com>
 <1392045915.30419.6.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "richardcochran@gmail.com" <richardcochran@gmail.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Stefan =?utf-8?B?U8O4cmVuc2Vu?= <stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:60839 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751770AbaBJPjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 10:39:09 -0500
Content-Disposition: inline
In-Reply-To: <1392045915.30419.6.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 03:25:15PM +0000, Stefan S=C3=B8rensen wrote:
> On Mon, 2014-02-10 at 13:42 +0000, Mark Rutland wrote:
>=20
> > Binding document please.
>=20
> Dang, I somehow managed to drop that from the patch. I will fix for t=
he
> next version.

Cheers.

>=20
> > > +	if (of_find_property(node, "dp83640,slave", NULL))
> > > +		dp83640->slave =3D true;
> >=20
> > Use of_property_read_bool.
>=20
> Fixed.
>=20
> > > +	prop =3D of_find_property(node, "dp83640,perout-gpios", &prople=
n);
> > > +	if (prop) {
> > > +		if (dp83640->slave) {
> > > +			pr_err("dp83640,perout-gpios property can not be set together=
 with dp83640,slave");
> > > +			return -EINVAL;
> > > +		}
> > > +
> > > +		clock->caps.n_per_out =3D proplen / sizeof(u32);
> > > +		if (clock->caps.n_per_out > N_EXT) {
> > > +			pr_err("dp83640,perout-gpios may not have more than %d entrie=
s",
> > > +			       N_EXT);
> > > +			return -EINVAL;
> > > +		}
> > > +		err =3D of_property_read_u32_array(node, "dp83640,perout-gpios=
",
> > > +						 clock->perout_gpios,
> > > +						 clock->caps.n_per_out);
> > > +		if (err < 0)
> > > +			return err;
> > > +	}
> >=20
> > This looks nothing like the standard gpio bindings. What _exactly_ =
is
> > this property describing?
>=20
> The dp83640 has a number of pins of which 8 of them can be used for
> either timestamping events or triggering changes at programmed
> intervals. These properties are used to configure which pins get
> assigned to what function.

Ok.

>=20
> > If this is not using the standard gpio bindings then this should be
> > renamed.
>=20
> Maybe a gpio->pin renaming?

That sounds good to me.

Thanks,
Mark.
