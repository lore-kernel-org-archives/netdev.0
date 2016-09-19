From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent
 channel counts.
Date: Mon, 19 Sep 2016 08:33:23 +0000
Message-ID: <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0047.outbound.protection.outlook.com ([104.47.33.47]:21216
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756183AbcISId0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:33:26 -0400
In-Reply-To: <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The existing code is inconsistent in reporting and accepting the combined
> channel count.  bnxt_get_channels() reports maximum combined as the
> maximum rx count.  bnxt_set_channels() accepts combined count that cannot=
 be
> bigger than max rx or max tx.
>=20
> For example, if max rx =3D 2 and max tx =3D 1, we report max supported co=
mbined to
> be 2.  But if the user tries to set combined to 2, it will fail because 2=
 is bigger
> than max tx which is 1.
>=20
> Fix the code to be consistent.  Max allowed combined =3D max(max_rx, max_=
tx).
> We will accept a combined channel count <=3D max(max_rx, max_tx).

Don't you mean the 'max allowed combined =3D min(max_rx, max_tx)'.
How does using 'max' change the faulty scenario you've described?
