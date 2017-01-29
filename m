From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 29 Jan 2017 17:26:13 +0000
Message-ID: <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153134.GC2223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0044.outbound.protection.outlook.com ([104.47.40.44]:59422
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751942AbdA2R0R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 12:26:17 -0500
In-Reply-To: <20170129153134.GC2223@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +/* Read Rx timestamp */
> > +static int qed_ptp_hw_read_rx_ts(struct qed_dev *cdev, u64
> > +*timestamp) {
> > +	struct qed_hwfn *p_hwfn =3D QED_LEADING_HWFN(cdev);
> > +	struct qed_ptt *p_ptt =3D p_hwfn->p_ptp_ptt;
> > +	u32 val;
> > +
> > +	*timestamp =3D 0;
> > +	val =3D qed_rd(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_SEQID);
> > +	if (!(val & QED_TIMESTAMP_MASK)) {
> > +		DP_INFO(p_hwfn, "Invalid Rx timestamp, buf_seqid =3D %d\n",
> val);
> > +		return -EINVAL;
> > +	}
> > +
> > +	val =3D qed_rd(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_TS_LSB);
> > +	*timestamp =3D qed_rd(p_hwfn, p_ptt,
> NIG_REG_LLH_PTP_HOST_BUF_TS_MSB);
>=20
> You can already "Reset timestamp register to allow new timestamp" at this
> point, before combining the MSB and LSB.

We could - but what difference would it make?

> > +	*timestamp <<=3D 32;
> > +	*timestamp |=3D val;
> > +
> > +	/* Reset timestamp register to allow new timestamp */
> > +	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_SEQID,
> > +	       QED_TIMESTAMP_MASK);
> > +
> > +	return 0;
> > +}=20
