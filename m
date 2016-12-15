From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [BISECTED] v4.9: OCTEON ethernet crash
Date: Thu, 15 Dec 2016 02:57:51 +0200
Message-ID: <20161215005751.457nm46shyjdt63q@raspberrypi-2.musicnaut.iki.fi>
References: <20161215003253.un6hk2ytl3auiztn@raspberrypi-2.musicnaut.iki.fi>
 <f70acf45-191d-215a-0019-420627a35d98@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        David Daney <ddaney@caviumnetworks.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh03.mail.saunalahti.fi ([62.142.5.109]:37053 "EHLO
        emh03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbcLOA5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:57:54 -0500
Content-Disposition: inline
In-Reply-To: <f70acf45-191d-215a-0019-420627a35d98@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Dec 14, 2016 at 04:41:13PM -0800, Florian Fainelli wrote:
> On 12/14/2016 04:32 PM, Aaro Koskinen wrote:
> > Git bisect points to:
> > 
> > commit ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461
> > Author: Florian Fainelli <f.fainelli@gmail.com>
> > Date:   Tue Dec 6 20:54:43 2016 -0800
> > 
> >     phy: Don't increment MDIO bus refcount unless it's a different owner
> > 
> > Reverting this patch from v4.9 fixes the issue...
> 
> This should help:
> 
> diff --git a/drivers/staging/octeon/ethernet.c
> b/drivers/staging/octeon/ethernet.c
> index 8130dfe89745..12ebc4d800c3 100644
> --- a/drivers/staging/octeon/ethernet.c
> +++ b/drivers/staging/octeon/ethernet.c
> @@ -770,6 +770,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
>                         /* Initialize the device private structure. */
>                         struct octeon_ethernet *priv = netdev_priv(dev);
> 
> +                       SET_NETDEV_DEV(dev, &pdev->dev);
>                         dev->netdev_ops = &cvm_oct_pow_netdev_ops;
>                         priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
>                         priv->port = CVMX_PIP_NUM_INPUT_PORTS;

No, it's still crashing.

A.
