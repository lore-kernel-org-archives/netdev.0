From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: amd-xgbe: Add support for MDIO attached PHYs
Date: Tue, 15 Nov 2016 08:17:26 -0600
Message-ID: <fec6f014-9d5d-8d5b-22f1-c3fe81ab35ee@amd.com>
References: <6e653058-6442-5bcf-7e02-3136780caffb@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0072.outbound.protection.outlook.com ([104.47.36.72]:24544
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752415AbcKOORd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:17:33 -0500
In-Reply-To: <6e653058-6442-5bcf-7e02-3136780caffb@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 7:07 AM, Colin Ian King wrote:
> Hi,
> 
> Commit:
> 
> amd-xgbe: Add support for MDIO attached PHYs
> 
>     Use the phylib support in the kernel to communicate with and control an
>     MDIO attached PHY. Use the hardware's MDIO communication mechanism to
>     communicate with the PHY.
> 
> 
> +static int xgbe_clr_gpio(struct xgbe_prv_data *pdata, unsigned int gpio)
> +{
> +       unsigned int reg;
> +
> +       if (gpio > 16)
> +               return -EINVAL;
> 
> is gpio in the range 0..15?
> 
> 	if (gpio > 15)
> 		return -EINVAL;

Yes, the GPIO range is 0 to 15. I'll submit a patch to change the
constraint check.

Thanks,
Tom

> 
> +
> +       reg = XGMAC_IOREAD(pdata, MAC_GPIOSR);
> +
> +       reg &= ~(1 << (gpio + 16));
> 
> if gpio is 16, we get 1 << 32 which I believe is undefined behaviour.
> 
> +       XGMAC_IOWRITE(pdata, MAC_GPIOSR, reg);
> +
> +       return 0;
> +}
> 
> 
> Same applies for function xgbe_clr_gpio().
> 
> Colin
> 
