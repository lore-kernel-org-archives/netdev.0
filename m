From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] netcp:Fix error checking in the function gbe_open
Date: Thu, 30 Jul 2015 15:44:35 -0400
Message-ID: <55BA7EA3.9020204@ti.com>
References: <1438280850-9613-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>, <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438280850-9613-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/2015 02:27 PM, Nicholas Krause wrote:
> This fixes error checking in the function gbe_open by checking if
> the function netcp_register_txhook has failed by returning a error
> code and if so jump to the goto label fail for handling internal
> failures in this function.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>   drivers/net/ethernet/ti/netcp_ethss.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
> index 9b7e0a3..e81e66b 100644
> --- a/drivers/net/ethernet/ti/netcp_ethss.c
> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
> @@ -2257,8 +2257,10 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
>   	if (ret)
>   		goto fail;
>
> -	netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
> -			      gbe_intf);
> +	ret = netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
> +				    gbe_intf);
> +	if (ret)
> +		goto fail;
>
>   	slave->open = true;
>   	netcp_ethss_update_link_state(gbe_dev, slave, ndev);
>
Acked-by: Murali Karicheri <m-karicheri2@ti.com>

-- 
Murali Karicheri
Linux Kernel, Keystone
