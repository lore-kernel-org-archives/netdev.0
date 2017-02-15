From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 03/13] net: ethernet: aquantia: Removed
 unnecessary comparsion "old_mtu == new_mtu".
Date: Wed, 15 Feb 2017 21:56:30 +0100
Message-ID: <5241cecb-206e-4999-b495-a6584790905d@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <a1cf5e938fa5997041c56cf898fadd830eb488f9.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:59615 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751338AbdBOU4j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:56:39 -0500
In-Reply-To: <a1cf5e938fa5997041c56cf898fadd830eb488f9.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
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
> +
>  	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>  	if (err < 0)
>  		goto err_exit;
> +
>  	ndev->mtu = new_mtu;
>
>  	if (netif_running(ndev)) {
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
