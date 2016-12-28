From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH RFC 5/5] qedf: Add FIP request handling
Date: Wed, 28 Dec 2016 10:11:55 +0100
Message-ID: <a076b54b-966b-d652-7a0f-6b84aacb0ded@suse.de>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-6-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1482520628-24207-6-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> =

> This patch adds handling for FIP requests and responses that are handled =
by
> the driver itself and not by libfcoe.
> =

> Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/scsi/qedf/qedf_fip.c | 267 +++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 267 insertions(+)
>  create mode 100644 drivers/scsi/qedf/qedf_fip.c
> =

> diff --git a/drivers/scsi/qedf/qedf_fip.c b/drivers/scsi/qedf/qedf_fip.c
> new file mode 100644
> index 0000000..4f185c6
> --- /dev/null
> +++ b/drivers/scsi/qedf/qedf_fip.c
> @@ -0,0 +1,267 @@
> +/*
> + *  QLogic FCoE Offload Driver
> + *  Copyright (c) 2016 Cavium Inc.
> + *
> + *  This software is available under the terms of the GNU General Public=
 License
> + *  (GPL) Version 2, available from the file COPYING in the main directo=
ry of
> + *  this source tree.
> + */
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +#include "qedf.h"
> +
> +extern const struct qed_fcoe_ops *qed_ops;
> +/*
> + * FIP VLAN functions that will eventually move to libfcoe.
> + */
> +
> +void qedf_fcoe_send_vlan_req(struct qedf_ctx *qedf)
> +{
> +	struct sk_buff *skb;
> +	char *eth_fr;
> +	int fr_len;
> +	struct fip_vlan *vlan;
> +#define MY_FIP_ALL_FCF_MACS        ((__u8[6]) { 1, 0x10, 0x18, 1, 0, 2 })
> +	static u8 my_fcoe_all_fcfs[ETH_ALEN] =3D MY_FIP_ALL_FCF_MACS;

Do you support VN2VN, too?

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		      zSeries & Storage
hare-l3A5Bk7waGM@public.gmane.org			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: J. Hawn, J. Guild, F. Imend=F6rffer, HRB 16746 (AG N=FCrnberg)
