From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v3 1/2] qed: Add infrastructure for PTP support.
Date: Mon, 6 Feb 2017 10:41:44 +0000
Message-ID: <BL2PR07MB2306BFF942FD6EE54400D1288D400@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170202125637.GA3191@netboy>
 <BL2PR07MB2306F69350DA91B9B2A2E3588D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0049.outbound.protection.outlook.com ([104.47.33.49]:48192
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750949AbdBFKlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 05:41:49 -0500
In-Reply-To: <BL2PR07MB2306F69350DA91B9B2A2E3588D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +		for (val =3D 0; val <=3D 7; val++) {
> > > +			period1 =3D div_s64(val * 1000000000, ppb);
> > > +			period1 -=3D 8;
> > > +			period1 >>=3D 4;
> > > +			if (period1 < 1)
> > > +				period1 =3D 1;
> > > +			if (period1 > 0xFFFFFFE)
> > > +				period1 =3D 0xFFFFFFE;
> > > +			period2 =3D period1 + 1;
> > > +
> > > +			temp =3D div_s64(val * 1000000000, (period1 * 16 + 8));
> > > +			dif1 =3D ppb - temp;
> > > +			if (dif1 < 0)
> > > +				dif1 =3D -dif1;
> > > +
> > > +			temp =3D div_s64(val * 1000000000, (period2 * 16 + 8));
> >
> > Forgetting the useless val=3D0 case, this still takes 21 64-bit
> > divisions on every adjustment.  There must be a better way.
> >
> > @tglx - Do you have a hint for Sudarsana?
>=20
> Maybe we can improve it a bit by making it even uglier and save one of th=
e
> divisions here; But that would still leave a 2-digit number of divisions.=
 I don't
> have an alternative algorithm that would solve that.

Apparently I was over optimistic; Tried pushing the ppb division
out of the loop, but truncation was insufficient and resulted in reduced
drift accuracy.

Richard - we're planning on sending v4 with the existing algorithm
[but without iterating on 'val =3D=3D 0']; If you have any suggestion for
improving this, please share it.

Thanks,
Yuval
