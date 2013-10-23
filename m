From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net v3] be2net: Warn users of possible broken
 functionality on BE2 cards with very old FW versions with latest driver
Date: Wed, 23 Oct 2013 11:29:08 +0000
Message-ID: <e55e41bb-9b34-4ed4-be3b-f8fee87bbca0@CMEXHTCAS1.ad.emulex.com>
References: <c04a1288-7c23-499a-ae32-d4334fd39065@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: Somnath Kotur <Somnath.Kotur@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:14737 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab3JWL3O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 07:29:14 -0400
In-Reply-To: <c04a1288-7c23-499a-ae32-d4334fd39065@CMEXHTCAS1.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls ignore this, sent this version out by mistake , will resend the correct one soon after this, extremely sorry for the inconvenience.

Thanks
Somnath

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Somnath Kotur
> Sent: Wednesday, October 23, 2013 1:49 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; Somnath Kotur
> Subject: [PATCH net v3] be2net: Warn users of possible broken functionality
> on BE2 cards with very old FW versions with latest driver
> 
> On very old FW versions < 4.0, the mailbox command to set interrupts on the
> card succeeds even though it is not supported and should have failed,
> leading to a scenario where interrupts do not work.
> Hence warn users to upgrade to a suitable FW version to avoid seeing broken
> functionality.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
> v3: Incorporated comments from Ben Hutchings and Joe Perches
> 
>  drivers/net/ethernet/emulex/benet/be.h      |   14 ++++++++++++++
>  drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
>  2 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be.h
> b/drivers/net/ethernet/emulex/benet/be.h
> index db02023..6a57051 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -696,6 +696,20 @@ static inline int qnq_async_evt_rcvd(struct
> be_adapter *adapter)
>  	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;  }
> 
> +static inline u32 fw_major_num(char *fw_ver_str) {
> +	u32 fw_major;
> +	char *next, *cp;
> +	char tmp_fw_ver[FW_VER_LEN];
> +
> +	strncpy(tmp_fw_ver, fw_ver_str, strlen(fw_ver_str));
> +	next = tmp_fw_ver;
> +	cp = strsep(&next, ".");
> +	sscanf(cp, "%i", &fw_major);
> +
> +	return fw_major;
> +}
> +
>  extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
>  		u16 num_popped);
>  extern void be_link_status_update(struct be_adapter *adapter, u8
> link_status); diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..d8da961 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3247,6 +3247,12 @@ static int be_setup(struct be_adapter *adapter)
> 
>  	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter-
> >fw_on_flash);
> 
> +	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
> +		dev_err(dev, "Firmware on card is old(%s), IRQs may not
> work.",
> +			adapter->fw_ver);
> +		dev_err(dev, "Please upgrade firmware to version >=
> 4.0\n");
> +	}
> +
>  	if (adapter->vlans_added)
>  		be_vid_config(adapter);
> 
> --
> 1.6.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
