From: Chad Dupuis <chad.dupuis@cavium.com>
Subject: Re: [Open-FCoE] [PATCH RFC 5/5] qedf: Add FIP request handling
Date: Mon, 9 Jan 2017 11:47:23 -0500
Message-ID: <alpine.OSX.2.00.1701091147040.1044@administrators-macbook-pro.local>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com> <1482520628-24207-6-git-send-email-chad.dupuis@cavium.com> <a076b54b-966b-d652-7a0f-6b84aacb0ded@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <martin.petersen@oracle.com>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        <linux-scsi@vger.kernel.org>, <yuval.mintz@cavium.com>
To: Hannes Reinecke <hare@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <a076b54b-966b-d652-7a0f-6b84aacb0ded@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 28 Dec 2016, 9:11am -0000, Hannes Reinecke wrote:

> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> > From: "Dupuis, Chad" <chad.dupuis@cavium.com>
> > 
> > This patch adds handling for FIP requests and responses that are handled by
> > the driver itself and not by libfcoe.
> > 
> > Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> > Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> > Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> > Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> > ---
> >  drivers/scsi/qedf/qedf_fip.c | 267 +++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 267 insertions(+)
> >  create mode 100644 drivers/scsi/qedf/qedf_fip.c
> > 
> > diff --git a/drivers/scsi/qedf/qedf_fip.c b/drivers/scsi/qedf/qedf_fip.c
> > new file mode 100644
> > index 0000000..4f185c6
> > --- /dev/null
> > +++ b/drivers/scsi/qedf/qedf_fip.c
> > @@ -0,0 +1,267 @@
> > +/*
> > + *  QLogic FCoE Offload Driver
> > + *  Copyright (c) 2016 Cavium Inc.
> > + *
> > + *  This software is available under the terms of the GNU General Public License
> > + *  (GPL) Version 2, available from the file COPYING in the main directory of
> > + *  this source tree.
> > + */
> > +#include <linux/if_ether.h>
> > +#include <linux/if_vlan.h>
> > +#include "qedf.h"
> > +
> > +extern const struct qed_fcoe_ops *qed_ops;
> > +/*
> > + * FIP VLAN functions that will eventually move to libfcoe.
> > + */
> > +
> > +void qedf_fcoe_send_vlan_req(struct qedf_ctx *qedf)
> > +{
> > +	struct sk_buff *skb;
> > +	char *eth_fr;
> > +	int fr_len;
> > +	struct fip_vlan *vlan;
> > +#define MY_FIP_ALL_FCF_MACS        ((__u8[6]) { 1, 0x10, 0x18, 1, 0, 2 })
> > +	static u8 my_fcoe_all_fcfs[ETH_ALEN] = MY_FIP_ALL_FCF_MACS;
> 
> Do you support VN2VN, too?

Not currently, no.

> 
> Cheers,
> 
> Hannes
> 
