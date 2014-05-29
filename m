From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net V2 2/2] libphy: Add stubs to hook IEEE MMD Register
 reads and writes
Date: Fri, 30 May 2014 00:17:07 +0400
Message-ID: <538795C3.8060905@cogentembedded.com>
References: <1401380913-4207-1-git-send-email-vbridgers2013@gmail.com> <1401380913-4207-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Vince Bridgers <vbridgers2013@gmail.com>, f.fainelli@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:60111 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbaE2URC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 16:17:02 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so498441lbg.30
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 13:17:00 -0700 (PDT)
In-Reply-To: <1401380913-4207-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/29/2014 08:28 PM, Vince Bridgers wrote:

> The Micrel ksz9021 PHY does not support standard IEEE standard MMD
> extended register access, therefore requires stubs to fail the read
> register method and do nothing for the write register method when
> libphy attempts to read and/or configure Energy Efficient Ethernet
> features in PHYS that do support those features. This problem
> was observed on an Altera Cyclone V SOC development kit that
> uses the Synopsys EMAC and the Micrel ksz9021 PHY. This patch
> was tested on the same board, and Energy Efficient Ethernet is
> now disabled as expected since the Micrel PHY does not support that
> feature.

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V2: Split libphy and Micrel specific changes into 2 patches
>      based on review comments
> ---
>   drivers/net/phy/micrel.c |   23 +++++++++++++++++++++++
>   1 file changed, 23 insertions(+)

> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index d849684..08e9c49 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -316,6 +316,27 @@ static int ksz8873mll_config_aneg(struct phy_device *phydev)
>   	return 0;
>   }
>
> +/* This routine returns -1 as an indication to the caller that the
> + * Micrel ksz9021 10/100/1000 PHY does not support standard IEEE
> + * MMD extended PHY registers.
> + */
> +static int
> +ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
> +		      int regnum)
> +{
> +	return -1;
> +}
> +
> +/* This routine does nothing since the Micrel ksz9021 does not support
> + * standard IEEE MMD extended PHY registers.
> + */
> +static void
> +ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
> +		      int regnum, u32 val)
> +{
> +	return;

    Not needed.

> +}
> +

WBR, Sergei
