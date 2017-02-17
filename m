From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 03/12] net: ethernet: aquantia: Removed
 unnecessary comparsion "old_mtu == new_mtu".
Date: Fri, 17 Feb 2017 23:41:57 +0100
Message-ID: <20170217224157.GO6096@lunn.ch>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
 <6b965301a08041d2a8d8537a25e8a0642fa6d669.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: Pavel Belous <Pavel.Belous@aquantia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44152 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935080AbdBQWmA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 17:42:00 -0500
Content-Disposition: inline
In-Reply-To: <6b965301a08041d2a8d8537a25e8a0642fa6d669.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 12:07:25AM +0300, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> This check is not needed. Function aq_ndev_change_mtu wont be called
> if mtu has not changed.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index c17c70a..e5539c8 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -102,17 +102,15 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
>  	struct aq_nic_s *aq_nic = netdev_priv(ndev);
>  	int err = 0;
>  
> -	if (new_mtu == ndev->mtu) {
> -		err = 0;
> -		goto err_exit;
> -	}
>  	if (new_mtu < 68) {
>  		err = -EINVAL;
>  		goto err_exit;
>  	}

You can set ndev->min_mtu and the core will do this check for you.

> +
>  	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>  	if (err < 0)
>  		goto err_exit;
> +

White space changes should be in a separate patch.

>  	ndev->mtu = new_mtu;

I think __dev_set_mtu() takes care of this for you.

  Andrew
