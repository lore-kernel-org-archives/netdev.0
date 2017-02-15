From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 05/13] net: ethernet: aquantia: Superfluous
 initialization of "err".
Date: Wed, 15 Feb 2017 22:01:31 +0100
Message-ID: <efdf06fe-3d48-cf9d-5d91-5ccfad0f5005@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <a5b35e411d8ab762f399ccd5b03408e15a16128c.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54185 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750719AbdBOVBn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:01:43 -0500
In-Reply-To: <a5b35e411d8ab762f399ccd5b03408e15a16128c.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> Fixed superfluous initialization of err.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index f7513cb..68c19d3 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -87,14 +87,8 @@ static int aq_ndev_close(struct net_device *ndev)
>  static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  {
>  	struct aq_nic_s *aq_nic = netdev_priv(ndev);
> -	int err = 0;
> -
> -	err = aq_nic_xmit(aq_nic, skb);
> -	if (err < 0)
> -		goto err_exit;
>
> -err_exit:
> -	return err;
> +	return aq_nic_xmit(aq_nic, skb);
>  }
>
>  static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
>

Just a nitpick: Now that ndev_start_xmit() is only an empty wrapper for
aq_nic_xmit() you can toss it completely and call aq_nic_xmit directly.

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
