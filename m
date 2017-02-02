From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v3 1/2] qed: Add infrastructure for PTP support.
Date: Thu, 2 Feb 2017 16:36:05 +0000
Message-ID: <BL2PR07MB2306F69350DA91B9B2A2E3588D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170202125637.GA3191@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:7744
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751298AbdBBQgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 11:36:09 -0500
In-Reply-To: <20170202125637.GA3191@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +		for (val =3D 0; val <=3D 7; val++) {
> > +			period1 =3D div_s64(val * 1000000000, ppb);
> > +			period1 -=3D 8;
> > +			period1 >>=3D 4;
> > +			if (period1 < 1)
> > +				period1 =3D 1;
> > +			if (period1 > 0xFFFFFFE)
> > +				period1 =3D 0xFFFFFFE;
> > +			period2 =3D period1 + 1;
> > +
> > +			temp =3D div_s64(val * 1000000000, (period1 * 16 + 8));
> > +			dif1 =3D ppb - temp;
> > +			if (dif1 < 0)
> > +				dif1 =3D -dif1;
> > +
> > +			temp =3D div_s64(val * 1000000000, (period2 * 16 + 8));
>=20
> Forgetting the useless val=3D0 case, this still takes 21 64-bit divisions=
 on every
> adjustment.  There must be a better way.
>=20
> @tglx - Do you have a hint for Sudarsana?

Maybe we can improve it a bit by making it even uglier
and save one of the divisions here; But that would still leave a 2-digit
number of divisions. I don't have an alternative algorithm that would
solve that.

I have to say I still don't see the importance of this -
I thought we've previously agree that the 'reasonable' scenario
wouldn't use this more than 16 times a second, so it's clearly
not datapath.
Optimizing stuff is great, but optimizing less critical paths
is partially wasted effort. As such - I don't think this should
be a 'blocking' criteria for the submission.

Having written all of that, If someone raises to the challenge
and can efficiently improve the logic, we'd obviously
be delighted to take whatever solution is given.

Thanks,
Yuval
