From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 09/13] net: ethernet: aquantia: Call
 netdev_register after all initialized.
Date: Wed, 15 Feb 2017 22:18:57 +0100
Message-ID: <f5c2d81b-ea13-735c-3a35-503c164c0ca3@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <b179996dea5a6799b6e3d68536b3e3532b207d5f.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:61688 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752232AbdBOVTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:19:25 -0500
In-Reply-To: <b179996dea5a6799b6e3d68536b3e3532b207d5f.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> netdev_register should be called when everything is initialized.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index e50fba2..daed4c1 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -260,16 +260,18 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
>  		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
>  	}
>  #endif
> -	err = register_netdev(self->ndev);
> -	if (err < 0)
> -		goto err_exit;
>
> -	self->is_ndev_registered = true;
>  	netif_carrier_off(self->ndev);
>
>  	for (i = AQ_CFG_VECS_MAX; i--;)
>  		aq_nic_ndev_queue_stop(self, i);
>
> +	err = register_netdev(self->ndev);
> +	if (err < 0)
> +		goto err_exit;
> +
> +	self->is_ndev_registered = true;
> +
>  err_exit:
>  	return err;
>  }
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
