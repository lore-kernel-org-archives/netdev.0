From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [RFC 15/19] RDMA/qedr: Add iWARP support in existing verbs.
Date: Tue, 27 Jun 2017 08:18:02 +0000
Message-ID: <DM2PR0701MB13924E652A0F1970BE3ECD5788DC0@DM2PR0701MB1392.namprd07.prod.outlook.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-16-git-send-email-Michal.Kalderon@cavium.com>
 <20170627052703.GL1248@mtr-leonro.local>
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
Received: from mail-sn1nam01on0061.outbound.protection.outlook.com ([104.47.32.61]:63786
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751473AbdF0ISF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 04:18:05 -0400
In-Reply-To: <20170627052703.GL1248@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky [mailto:leon@kernel.org]
Sent: Tuesday, June 27, 2017 8:27 AM
=20
> On Mon, Jun 26, 2017 at 09:07:05PM +0300, Michal Kalderon wrote:
> > Make slight modifications to common RoCE/iWARP code.
> > Add additional doorbell for iWARP post_send.
> > iWARP QP pbl is allocated in qed and not in qedr.
> >
> > Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> > Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
> > Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
> >
> > ---
> >  drivers/infiniband/hw/qedr/qedr.h  |   3 +
> >  drivers/infiniband/hw/qedr/verbs.c | 171
> +++++++++++++++++++++++++++++--------
> >  2 files changed, 139 insertions(+), 35 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/qedr/qedr.h
> b/drivers/infiniband/hw/qedr/qedr.h
> > index c52fde0..0c0a39a 100644
> > --- a/drivers/infiniband/hw/qedr/qedr.h
> > +++ b/drivers/infiniband/hw/qedr/qedr.h
> > @@ -319,6 +319,9 @@ struct qedr_qp_hwq_info {
> >  	/* DB */
> >  	void __iomem *db;
> >  	union db_prod32 db_data;
> > +
> > +	void __iomem *iwarp_db2;
> > +	union db_prod32 iwarp_db2_data;
>=20
> Why do you need two doorbells?

This is a hw requirement to handle error state in iWARP=20
> >  };
