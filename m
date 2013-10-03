From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net] be2net: Warn users of possible broken functionality
 on BE2 cards with very old F/W versions with latest driver.
Date: Thu, 3 Oct 2013 07:11:04 +0000
Message-ID: <47924b8a-63d9-4ed3-b3be-7fe9e0f525b1@CMEXHTCAS2.ad.emulex.com>
References: <e84f68dc-6ab3-4e56-b2f5-70e51c46d1c3@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Somnath Kotur <Somnath.Kotur@Emulex.Com>
To: Somnath Kotur <Somnath.Kotur@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28512 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673Ab3JCHLK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 03:11:10 -0400
In-Reply-To: <e84f68dc-6ab3-4e56-b2f5-70e51c46d1c3@CMEXHTCAS1.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf
> Of Somnath Kotur
> 
> On very old F/W versions < 4.0, the mailbox command to set interrupts on the
> card succeeds even though it is not supported and should have failed leading to
> interrupts not working.
> Hence warn users to upgrade to a suitable F/W version to avoid seeing broken
> functionality.
> 

Som, we've already use the term "FW" (instead of "F/W") at various places in the
code. Can you pls stick to this.
This is important especially for log messages. "FW" (similar to "HW" ) is much more
commonly used and more readable.

> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..f4bbc92 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3247,6 +3247,11 @@ static int be_setup(struct be_adapter *adapter)
> 
>  	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
> 
> +	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
> +		dev_err(dev, "F/W version is very old. IRQs may not work\n");
> +		dev_err(dev, "Pls upgrade to F/W version >= 4.0\n");
> +	}

Same as above.

> +
>  	if (adapter->vlans_added)
>  		be_vid_config(adapter);
> 
> --
> 1.6.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
