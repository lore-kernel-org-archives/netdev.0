From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] staging: octeon: Call SET_NETDEV_DEV()
Date: Tue, 20 Dec 2016 17:02:37 -0800
Message-ID: <d5cd5832-4402-2468-9d64-0a8d6e62d965@gmail.com>
References: <20161215011326.8852-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Laura Garcia Liebana <nevola@gmail.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>,
        Jarod Wilson <jarod@redhat.com>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215011326.8852-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2016 05:13 PM, Florian Fainelli wrote:
> The Octeon driver calls into PHYLIB which now checks for
> net_device->dev.parent, so make sure we do set it before calling into
> any MDIO/PHYLIB related function.
> 
> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
> Reported-by: Aaro Koskinen <aaro.koskinen@iki.fi>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Greg, David, since this is a fix for a regression introduced in the net
tree, it may make sense that David take it via his tree.

Thanks

> ---
>  drivers/staging/octeon/ethernet.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
> index 8130dfe89745..4971aa54756a 100644
> --- a/drivers/staging/octeon/ethernet.c
> +++ b/drivers/staging/octeon/ethernet.c
> @@ -770,6 +770,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
>  			/* Initialize the device private structure. */
>  			struct octeon_ethernet *priv = netdev_priv(dev);
>  
> +			SET_NETDEV_DEV(dev, &pdev->dev);
>  			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
>  			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
>  			priv->port = CVMX_PIP_NUM_INPUT_PORTS;
> @@ -816,6 +817,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
>  			}
>  
>  			/* Initialize the device private structure. */
> +			SET_NETDEV_DEV(dev, &pdev->dev);
>  			priv = netdev_priv(dev);
>  			priv->netdev = dev;
>  			priv->of_node = cvm_oct_node_for_port(pip, interface,
> 


-- 
Florian
