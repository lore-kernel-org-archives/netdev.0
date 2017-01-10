From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH RFC 5/5] qedf: Add FIP request handling
Date: Tue, 10 Jan 2017 07:58:12 +0100
Message-ID: <9cce615f-3d83-59ea-1fe1-e08bc4265dc5@suse.de>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-6-git-send-email-chad.dupuis@cavium.com>
 <a076b54b-966b-d652-7a0f-6b84aacb0ded@suse.de>
 <alpine.OSX.2.00.1701091147040.1044@administrators-macbook-pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <alpine.OSX.2.00.1701091147040.1044-nVgGmETfwnIFUnR/tdpssI0aTaFgKE92ACYyPGjX6YU@public.gmane.org>
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

On 01/09/2017 05:47 PM, Chad Dupuis wrote:
> =

> On Wed, 28 Dec 2016, 9:11am -0000, Hannes Reinecke wrote:
> =

>> On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
>>> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>>
>>> This patch adds handling for FIP requests and responses that are handle=
d by
>>> the driver itself and not by libfcoe.
>>>
>>> Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>> Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  drivers/scsi/qedf/qedf_fip.c | 267 +++++++++++++++++++++++++++++++++++=
++++++++
>>>  1 file changed, 267 insertions(+)
>>>  create mode 100644 drivers/scsi/qedf/qedf_fip.c
>>>
>>> diff --git a/drivers/scsi/qedf/qedf_fip.c b/drivers/scsi/qedf/qedf_fip.c
>>> new file mode 100644
>>> index 0000000..4f185c6
>>> --- /dev/null
>>> +++ b/drivers/scsi/qedf/qedf_fip.c
>>> @@ -0,0 +1,267 @@
>>> +/*
>>> + *  QLogic FCoE Offload Driver
>>> + *  Copyright (c) 2016 Cavium Inc.
>>> + *
>>> + *  This software is available under the terms of the GNU General Publ=
ic License
>>> + *  (GPL) Version 2, available from the file COPYING in the main direc=
tory of
>>> + *  this source tree.
>>> + */
>>> +#include <linux/if_ether.h>
>>> +#include <linux/if_vlan.h>
>>> +#include "qedf.h"
>>> +
>>> +extern const struct qed_fcoe_ops *qed_ops;
>>> +/*
>>> + * FIP VLAN functions that will eventually move to libfcoe.
>>> + */
>>> +
>>> +void qedf_fcoe_send_vlan_req(struct qedf_ctx *qedf)
>>> +{
>>> +	struct sk_buff *skb;
>>> +	char *eth_fr;
>>> +	int fr_len;
>>> +	struct fip_vlan *vlan;
>>> +#define MY_FIP_ALL_FCF_MACS        ((__u8[6]) { 1, 0x10, 0x18, 1, 0, 2=
 })
>>> +	static u8 my_fcoe_all_fcfs[ETH_ALEN] =3D MY_FIP_ALL_FCF_MACS;
>>
>> Do you support VN2VN, too?
> =

> Not currently, no.
> =

Ah.

Too bad. Any plans for it?
It certainly eases up P2P setups for FCoE...

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare-l3A5Bk7waGM@public.gmane.org			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: F. Imend=F6rffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG N=FCrnberg)
