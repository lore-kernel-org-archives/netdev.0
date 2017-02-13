From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: FW: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Mon, 13 Feb 2017 09:48:09 +0000
Message-ID: <BL2PR07MB23060D923FD9B8C08E0FE2808D590@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170211085810.GA4006@localhost.localdomain>
 <20170211111638.GA6564@localhost.localdomain>
 <BL2PR07MB2306C87FF3E79B221675F5848D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170212140202.GA1702@localhost.localdomain>
 <BL2PR07MB2306751ABE3FC347E40302B18D460@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170212195027.GA2696@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0047.outbound.protection.outlook.com ([104.47.33.47]:35392
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751007AbdBMJsO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 04:48:14 -0500
In-Reply-To: <20170212195027.GA2696@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, Feb 12, 2017 at 03:07:34PM +0000, Mintz, Yuval wrote:
> > Your algorithm ignores the HW limitation. Consider (ppb =3D=3D 1):
> > your logic would output N =3D=3D 7, *M =3D=3D 7000000000,
> >    Which has perfect accuracy [N / *M is 1 / 10^9].
> > But the solution for
> >    'period' * 16 + 8 =3D=3D 7 * 10^9
> > isn't a whole number, so this result doesn't really reflect the actual
> > approximation error since we couldn't configure it to HW.
>=20
> Ok, so change my code to read:
>=20
> 		/*truncate to HW resolution*/
> 		reg =3D (m - 8) / 16;
> 		m =3D reg * 16 + 8;
>=20
> Your HW will happyly accept the value of 'reg', right?
>=20
> > The original would return val =3D=3D 1, period =3D=3D 62499999; While t=
his
> > does have some error [val / (period * 16 + 8) is slightly bigger than
> > 1 / 10^9, error at 18[?] digit after dot], it's the best we can
> > configure for the HW.
>=20
> That is *not* the best you can do:

I have already conceded that in a different reply to this thread.

In light of the difference I re-checked our calculation and found
that we lose precision due to the later divisions' truncation.
I.e., currently:
   Diff =3D=3D | ppb - 10^9 * val / (period * 16 +8)|
Which can be transformed into:
   Diff =3D=3D | ppb * (period * 16 + 8) - 10^9 * val |

It would reduce the approximation error as well as remove
2 divisions from each iteration.

I'll send v5 with it later today.
