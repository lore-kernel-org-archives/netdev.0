From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when using devicetrees.
Date: Thu, 15 Nov 2012 16:59:49 +0000
Message-ID: <20121115165949.942993E194B@localhost>
References: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Cc: devicetree-discuss@lists.ozlabs.org, davem@davemloft.net
To: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:44100 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768440Ab2KOQ7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 11:59:54 -0500
Received: by mail-wg0-f44.google.com with SMTP id dr13so939790wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 08:59:53 -0800 (PST)
In-Reply-To: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 14:26:13 +0000, Srinivas KANDAGATLA <srinivas.kandagatla@st.com> wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> When the mdio-gpio driver is probed via device trees, the platform
> device id is set as -1, However the id is re-used in the code while
> creating an mdio bus.
> So, setting up the id via aliases from device tree is a sensible
> solution to fix this issue.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> ---
>  .../devicetree/bindings/net/mdio-gpio.txt          |    9 ++++++++-
>  drivers/net/phy/mdio-gpio.c                        |    1 +
>  2 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mdio-gpio.txt b/Documentation/devicetree/bindings/net/mdio-gpio.txt
> index bc95495..c79bab0 100644
> --- a/Documentation/devicetree/bindings/net/mdio-gpio.txt
> +++ b/Documentation/devicetree/bindings/net/mdio-gpio.txt
> @@ -8,9 +8,16 @@ gpios property as described in section VIII.1 in the following order:
>  
>  MDC, MDIO.
>  
> +Note: Each gpio-mdio bus should have an alias correctly numbered in "aliases"
> +node.
> +
>  Example:
>  
> -mdio {
> +aliases {
> +	mdio-gpio0 = <&mdio0>;
> +};
> +
> +mdio0: mdio {
>  	compatible = "virtual,mdio-gpio";
>  	#address-cells = <1>;
>  	#size-cells = <0>;
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> index 899274f..e3f3115 100644
> --- a/drivers/net/phy/mdio-gpio.c
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -56,6 +56,7 @@ static void *mdio_gpio_of_get_data(struct platform_device *pdev)
>  	if (ret < 0)
>  		return NULL;
>  	pdata->mdio = ret;
> +	pdev->id = of_alias_get_id(np, "mdio-gpio");

This is actually illegal. Once a device is registered, pdev->id must not
be changed. Same goes for pdev->name and pdev->dev.platform_data.

g.
