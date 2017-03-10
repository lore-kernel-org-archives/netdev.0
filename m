From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: tun: use new api ethtool_{get|set}_link_ksettings
Date: Fri, 10 Mar 2017 23:57:41 +0200
Message-ID: <20170310235719-mutt-send-email-mst@kernel.org>
References: <1489180687-19623-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com, pabeni@redhat.com,
        fgao@48lvckh6395k16k5.yundunddos.com,
        elfring@users.sourceforge.net, jarno@ovn.org,
        rppt@linux.vnet.ibm.com, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489180687-19623-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2017 at 10:18:07PM +0100, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware,

What kind of hardware?

> I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/tun.c |   24 +++++++++++-------------
>  1 files changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index dc1b1dd..c418f0a 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -2430,18 +2430,16 @@ static void tun_chr_show_fdinfo(struct seq_file *m, struct file *f)
>  
>  /* ethtool interface */
>  
> -static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> -{
> -	cmd->supported		= 0;
> -	cmd->advertising	= 0;
> -	ethtool_cmd_speed_set(cmd, SPEED_10);
> -	cmd->duplex		= DUPLEX_FULL;
> -	cmd->port		= PORT_TP;
> -	cmd->phy_address	= 0;
> -	cmd->transceiver	= XCVR_INTERNAL;
> -	cmd->autoneg		= AUTONEG_DISABLE;
> -	cmd->maxtxpkt		= 0;
> -	cmd->maxrxpkt		= 0;
> +static int tun_get_link_ksettings(struct net_device *dev,
> +				  struct ethtool_link_ksettings *cmd)
> +{
> +	ethtool_link_ksettings_zero_link_mode(cmd, supported);
> +	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
> +	cmd->base.speed		= SPEED_10;
> +	cmd->base.duplex	= DUPLEX_FULL;
> +	cmd->base.port		= PORT_TP;
> +	cmd->base.phy_address	= 0;
> +	cmd->base.autoneg	= AUTONEG_DISABLE;
>  	return 0;
>  }
>  
> @@ -2504,7 +2502,6 @@ static int tun_set_coalesce(struct net_device *dev,
>  }
>  
>  static const struct ethtool_ops tun_ethtool_ops = {
> -	.get_settings	= tun_get_settings,
>  	.get_drvinfo	= tun_get_drvinfo,
>  	.get_msglevel	= tun_get_msglevel,
>  	.set_msglevel	= tun_set_msglevel,
> @@ -2512,6 +2509,7 @@ static int tun_set_coalesce(struct net_device *dev,
>  	.get_ts_info	= ethtool_op_get_ts_info,
>  	.get_coalesce   = tun_get_coalesce,
>  	.set_coalesce   = tun_set_coalesce,
> +	.get_link_ksettings = tun_get_link_ksettings,
>  };
>  
>  static int tun_queue_resize(struct tun_struct *tun)
> -- 
> 1.7.4.4
