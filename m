From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: caif: chnl_net: remove unnecessary null check in
 chnl_recv_cb
Date: Mon, 30 Oct 2017 18:33:38 -0500
Message-ID: <20171030183338.Horde.vVqSFCm_FOajDoq8fJoJ13P@gator4166.hostgator.com>
References: <20171030224714.GA31045@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030224714.GA31045@embeddedor.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Quoting "Gustavo A. R. Silva" <garsilva@embeddedor.com>:

> container_of is never null, so this null check is unnecessary.
>
> This code was detected with the help of Coccinelle.
>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  net/caif/chnl_net.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
> index 922ac1d..489298d 100644
> --- a/net/caif/chnl_net.c
> +++ b/net/caif/chnl_net.c
> @@ -77,8 +77,6 @@ static int chnl_recv_cb(struct cflayer *layr,  
> struct cfpkt *pkt)
>  	u8 buf;
>
>  	priv = container_of(layr, struct chnl_net, chnl);
> -	if (!priv)
> -		return -EINVAL;
>
>  	skb = (struct sk_buff *) cfpkt_tonative(pkt);
>
> --
> 2.7.4

Please, ignore this patch.

I just realized that function chnl_recv_cb is being called only during  
initialization:

chnl_init_module() -> rtnl_link_register() -> ipcaif_net_setup() ->  
chnl_recv_cb():

static void ipcaif_net_setup(struct net_device *dev)
{
[...]
	priv = netdev_priv(dev);
	priv->chnl.receive = chnl_recv_cb;

[...]
}

static struct rtnl_link_ops ipcaif_link_ops __read_mostly = {
	.kind		= "caif",
	.priv_size	= sizeof(struct chnl_net),
	.setup		= ipcaif_net_setup,
	.maxtype	= IFLA_CAIF_MAX,
	.policy		= ipcaif_policy,
	.newlink	= ipcaif_newlink,
	.changelink	= ipcaif_changelink,
	.get_size	= ipcaif_get_size,
	.fill_info	= ipcaif_fill_info,

};

static int __init chnl_init_module(void)
{
	return rtnl_link_register(&ipcaif_link_ops);
}

Thanks
--
Gustavo A. R. Silva
