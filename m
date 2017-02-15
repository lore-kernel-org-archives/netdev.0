From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 06/13] net: ethernet: aquantia: Fixed missing
 rtnl_unlock.
Date: Wed, 15 Feb 2017 22:02:00 +0100
Message-ID: <f35a2bff-cd99-812c-8940-1046bc75d130@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <030e8676b6d69a33e805f86dc97f1e2136527eeb.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:61246 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751298AbdBOVCI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:02:08 -0500
In-Reply-To: <030e8676b6d69a33e805f86dc97f1e2136527eeb.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> rtnl_unlock should be called if error occurred.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index a153750..1bf5975 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -931,7 +931,7 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
>
>  	if (!netif_running(self->ndev)) {
>  		err = 0;
> -		goto err_exit;
> +		goto out;
>  	}
>  	rtnl_lock();
>  	if (pm_msg->event & PM_EVENT_SLEEP || pm_msg->event & PM_EVENT_FREEZE) {
> @@ -956,8 +956,9 @@ int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
>  		netif_device_attach(self->ndev);
>  		netif_tx_start_all_queues(self->ndev);
>  	}
> -	rtnl_unlock();
>
>  err_exit:
> +	rtnl_unlock();
> +out:
>  	return err;
>  }
>

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Regards,
Lino
