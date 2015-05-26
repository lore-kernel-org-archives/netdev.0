From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Add TI dp83867 phy
Date: Tue, 26 May 2015 11:04:18 -0700
Message-ID: <5564B5A2.4080508@gmail.com>
References: <1432645679-4759-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36211 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbbEZSEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:04:53 -0400
Received: by pdfh10 with SMTP id h10so96080232pdf.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 11:04:52 -0700 (PDT)
In-Reply-To: <1432645679-4759-1-git-send-email-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/05/15 06:07, Dan Murphy wrote:
> Add support for the TI dp83867 Gigabit ethernet phy
> device.
> 
> The DP83867 is a robust, low power, fully featured
> Physical Layer transceiver with integrated PMD
> sublayers to support 10BASE-T, 100BASE-TX and
> 1000BASE-T Ethernet protocols.
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>
> ---
[snip]

> +
> +int rx_tx_delay = (DP83867_RGMIIDCTL_2_75_NS << DP83867_RGMII_RX_CLK_DELAY_SHIFT) | DP83867_RGMIIDCTL_2_25_NS;
> +module_param(rx_tx_delay, int, 0664);

This is not going to work, rx and tx delays are inherent properties of
PCB/board designs, you want to be able to get that value from your
platform configuration, Device Tree would certainly be preferred here.
Asking an user to figure this out through module parameters is going to
be both error prone, and limiting yourself to no more than one instance.

[snip]

> +
> +static int dp83867_phy_reset(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	err = phy_write(phydev, DP83867_CTRL, DP83867_SW_RESET);
> +	if (err < 0)
> +		return err;
> +
> +	err = dp83867_config_init(phydev);
> +	return err;

you could do a tail-call return directly?

[snip]

> +
> +static int __init dp83867_init(void)
> +{
> +	return phy_driver_register(&dp83867_driver);
> +}
> +
> +static void __exit dp83867_exit(void)
> +{
> +	phy_driver_unregister(&dp83867_driver);
> +}
> +
> +module_init(dp83867_init);
> +module_exit(dp83867_exit);

You could use module_phy_driver to eliminate some boilerplate here.
-- 
Florian
