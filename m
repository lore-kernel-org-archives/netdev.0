From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v5 1/2] qed: Add infrastructure for PTP support
Date: Mon, 13 Feb 2017 21:51:08 +0000
Message-ID: <BL2PR07MB230666FC45C1F86F774FE2B18D590@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1486993586-16431-1-git-send-email-Yuval.Mintz@cavium.com>
 <1486993586-16431-2-git-send-email-Yuval.Mintz@cavium.com>
 <20170213202550.GA3005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0072.outbound.protection.outlook.com ([104.47.32.72]:38838
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752492AbdBMVvM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 16:51:12 -0500
In-Reply-To: <20170213202550.GA3005@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static int qed_ptp_hw_adjfreq(struct qed_dev *cdev, s32 ppb) {
> > +	struct qed_hwfn *p_hwfn =3D QED_LEADING_HWFN(cdev);
> > +	struct qed_ptt *p_ptt =3D p_hwfn->p_ptp_ptt;
> > +	int drift_dir, best_val, best_period;
> > +	s64 period, dif, dif2;
> > +	u32 drift_ctr_cfg =3D 0;
> > +	s64 best_dif, val;
> > +	u32 drift_state;
> > +
> > +	best_dif =3D ppb;

Crap. Apparently I've sent my early draft.

'best_dif' is the culprit for the odd results [not the -8].
In the previous calculation it was the theoretical upper-bound,
now it should be an unreachable number instead [7000000000].

> > +	best_period =3D 2;
> > +	best_val =3D 0;
> > +	drift_dir =3D 1;
> > +
> > +	if (ppb < 0) {
> > +		ppb =3D -ppb;
> > +		drift_dir =3D 0;
> > +	}
> > +
> > +	if (ppb =3D=3D 0) {
> > +		/* No clock adjustment required */
> > +		best_val =3D 0;
> > +		best_period =3D 0xFFFFFFF;
> > +	} else {
> > +		/* Adjustment value is up to +/-7ns, find an optimal value in
> > +		 * this range.
> > +		 */
> > +		for (val =3D 7; val > 0; val++) {
>=20
> This is an endless loop. ------------- ^^^^^

And this, obviously...

>=20
> Besides that, this code returns some very strange values.  For example, f=
or
> ppb =3D 100106, 100107, and 100108.  Also ppb =3D 1...8 all return 0/40.
>=20
> Trouble with the -=3D 8?
>=20
> I can only recommend plotting all of the raw errors and also average
> (RMS) error over the nominal interval ppb =3D 1...500000.
>=20

I'll send the corrected v6 tomorrow. Sorry about this one.
