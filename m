From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 08/13] net: ethernet: aquantia: Null pointer
 check for aq_nic_ndev_alloc.
Date: Wed, 15 Feb 2017 22:04:16 +0100
Message-ID: <3b66425c-975d-a829-2dff-d48ee6862ab2@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <34586a7fe70a07e8713b20e82a2191a3530b8ff1.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58430 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751338AbdBOVE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:04:26 -0500
In-Reply-To: <34586a7fe70a07e8713b20e82a2191a3530b8ff1.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> We should check for a null pointer for aq_nic_ndev_alloc
> instead netdev_priv.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index 4cf633c..e50fba2 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -202,12 +202,13 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
>  	int err = 0;
>
>  	ndev = aq_nic_ndev_alloc();
> -	self = netdev_priv(ndev);
> -	if (!self) {
> -		err = -EINVAL;
> +	if (!ndev) {
> +		err = -ENOMEM;
>  		goto err_exit;
>  	}
>
> +	self = netdev_priv(ndev);
> +
>  	ndev->netdev_ops = ndev_ops;
>  	ndev->ethtool_ops = et_ops;
>
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
