From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [RFC 01/19] qed: Introduce iWARP personality
Date: Tue, 27 Jun 2017 08:17:10 +0000
Message-ID: <DM2PR0701MB13928FCD579EB9B45F665CB488DC0@DM2PR0701MB1392.namprd07.prod.outlook.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-2-git-send-email-Michal.Kalderon@cavium.com>
 <20170627053635.GM1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0084.outbound.protection.outlook.com ([104.47.40.84]:8352
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751473AbdF0IRN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 04:17:13 -0400
In-Reply-To: <20170627053635.GM1248@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky [mailto:leon@kernel.org]
Sent: Tuesday, June 27, 2017 8:37 AM
>=20
> On Mon, Jun 26, 2017 at 09:06:51PM +0300, Michal Kalderon wrote:
> > iWARP personality introduced the need for differentiating in several
> > places in the code whether we are RoCE, iWARP or either. This leads to
> > introducing new macros for querying the personality.
> >
> > Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> > Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
> >
> > ---
> >  drivers/net/ethernet/qlogic/qed/qed.h      | 26 ++++++++++++++++++++++=
+--
> -
> >  drivers/net/ethernet/qlogic/qed/qed_cxt.c  |  8 ++++----
> > drivers/net/ethernet/qlogic/qed/qed_dev.c  | 12 +++++-------
> >  drivers/net/ethernet/qlogic/qed/qed_l2.c   |  3 +--
> >  drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  2 +-
> > drivers/net/ethernet/qlogic/qed/qed_main.c | 17 ++++++++---------
> >  include/linux/qed/common_hsi.h             |  2 +-
> >  7 files changed, 43 insertions(+), 27 deletions(-)
>=20
> I see that these changes are in Ethernet part of your driver, but for RDM=
A part,
> there are already available inline functions:
> rdma_protocol_iwarp, rdma_protocol_roce.
>=20
> Please avoid introducing new IS_IWARP/IS_ROCE macros and the decision
> should be taken on port level and not on device, despite the fact that pr=
obably
> your ib_device has only one port.
>=20
> Thanks

We still need to differentiate between iWARP/RoCE before rdma_protocol_iwar=
p/rdma_protocol_roce will be valid
(allocating resources, registering ib device, initializing ib_device, and c=
apabilities.
For the rest of the places, after the port capabilities are valid, we'll us=
e the inline functions.
