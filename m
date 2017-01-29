From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Sun, 29 Jan 2017 17:30:51 +0000
Message-ID: <BL2PR07MB2306088B2179138BB4557FE58D480@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0053.outbound.protection.outlook.com ([104.47.32.53]:23505
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751215AbdA2RbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 12:31:09 -0500
In-Reply-To: <20170129153536.GD2223@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static int qede_ptp_adjfreq(struct ptp_clock_info *info, s32 ppb) {
> > +	struct qede_ptp *ptp =3D container_of(info, struct qede_ptp,
> clock_info);
> > +	struct qede_dev *edev =3D ptp->edev;
> > +	int rc;
> > +
> > +	__qede_lock(edev);
> > +	if (edev->state =3D=3D QEDE_STATE_OPEN) {
> > +		spin_lock_bh(&ptp->lock);
> > +		rc =3D ptp->ops->adjfreq(edev->cdev, ppb);
>=20
> Why add this extra layer of indirection?
>=20
> You could put these this test into qed_ptp_hw_adjfreq() and register that
> function directly.
>=20

Which level of indirection? The usage of ptp->ops->() functions?

That's part of the driver structuring - qed is responsible for accessing HW
so it implements api functions for accessing PTP-related configuration,
while qede is responsible for the network interface and thus is the one to
register the clock and implements its API.

The operations ptp->ops->() originate from qed, so we can't refactor qede
state-logic there and use it directly.
