From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [net-next] macvlan: propagate the mac address change status for
 lowerdev
Date: Tue, 13 Jun 2017 23:34:09 +0300
Message-ID: <20170613203408.GA3112@yuvallap>
References: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fgao@48lvckh6395k16k5.yundunddos.com,
        vyasevic@redhat.com, netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37019 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751793AbdFMUe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:34:58 -0400
Content-Disposition: inline
In-Reply-To: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 10:45:11PM +0800, Zhang Shengju wrote:
> The macvlan dev should propagate the return value of mac address change for
> lower device in the passthru mode, instead of always return 0.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  drivers/net/macvlan.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 346ad2f..ade1213 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -703,10 +703,8 @@ static int macvlan_set_mac_address(struct net_device *dev, void *p)
>  	if (!is_valid_ether_addr(addr->sa_data))
>  		return -EADDRNOTAVAIL;
>  
> -	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
> -		dev_set_mac_address(vlan->lowerdev, addr);
> -		return 0;
> -	}
> +	if (vlan->mode == MACVLAN_MODE_PASSTHRU)
> +		return dev_set_mac_address(vlan->lowerdev, addr);

Do you think the following functions needs this fix as well?
- alb_set_mac_address
- bond_alb_handle_active_change
- bond_enslave
- __bond_release_one
- macvlan_set_mac_address

Yuval

>  
>  	return macvlan_sync_address(dev, addr->sa_data);
>  }
> -- 
> 1.8.3.1
> 
> 
> 
