From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net 1/7] bnx2x: prevent crash when accessing PTP with
 interface down
Date: Sun, 5 Mar 2017 09:43:47 +0000
Message-ID: <BL2PR07MB23062D54948BD583E2B7D7318D2D0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
 <20170303160834.4125-2-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>
To: Michal Schmidt <mschmidt@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0078.outbound.protection.outlook.com ([104.47.40.78]:54624
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750732AbdCEJnv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 04:43:51 -0500
In-Reply-To: <20170303160834.4125-2-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It is possible to crash the kernel by accessing a PTP device while its
> associated bnx2x interface is down. Before the interface is brought up, t=
he
> timecounter is not initialized, so accessing it results in NULL dereferen=
ce.
>=20
> Fix it by checking if the interface is up.
>=20
> Use -ENETDOWN as the error code when the interface is down.
>  -EFAULT in bnx2x_ptp_adjfreq() did not seem right.
>=20
> Tested using phc_ctl get/set/adj/freq commands.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

While I have no objections to the patch contents, does it even make
sense to try adjusting frequencies on a DOWNed interface?
Wouldn't it make more sense checking this in the calling context
Instead?
