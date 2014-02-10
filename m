From: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: Re: [PATCH] dp83640: Get gpio and master/slave configuration from DT
Date: Mon, 10 Feb 2014 16:25:15 +0100
Message-ID: <1392045915.30419.6.camel@e37108.spectralink.com>
References: <1392037240-30913-1-git-send-email-stefan.sorensen@spectralink.com>
	 <20140210134237.GF29080@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "richardcochran@gmail.com" <richardcochran@gmail.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.244] ([207.46.163.244]:55926 "EHLO
	na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751970AbaBJP1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 10:27:18 -0500
In-Reply-To: <20140210134237.GF29080@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 13:42 +0000, Mark Rutland wrote:

> Binding document please.

Dang, I somehow managed to drop that from the patch. I will fix for the
next version.

> > +	if (of_find_property(node, "dp83640,slave", NULL))
> > +		dp83640->slave = true;
> 
> Use of_property_read_bool.

Fixed.

> > +	prop = of_find_property(node, "dp83640,perout-gpios", &proplen);
> > +	if (prop) {
> > +		if (dp83640->slave) {
> > +			pr_err("dp83640,perout-gpios property can not be set together with dp83640,slave");
> > +			return -EINVAL;
> > +		}
> > +
> > +		clock->caps.n_per_out = proplen / sizeof(u32);
> > +		if (clock->caps.n_per_out > N_EXT) {
> > +			pr_err("dp83640,perout-gpios may not have more than %d entries",
> > +			       N_EXT);
> > +			return -EINVAL;
> > +		}
> > +		err = of_property_read_u32_array(node, "dp83640,perout-gpios",
> > +						 clock->perout_gpios,
> > +						 clock->caps.n_per_out);
> > +		if (err < 0)
> > +			return err;
> > +	}
> 
> This looks nothing like the standard gpio bindings. What _exactly_ is
> this property describing?

The dp83640 has a number of pins of which 8 of them can be used for
either timestamping events or triggering changes at programmed
intervals. These properties are used to configure which pins get
assigned to what function.

> If this is not using the standard gpio bindings then this should be
> renamed.

Maybe a gpio->pin renaming?

Stefan
