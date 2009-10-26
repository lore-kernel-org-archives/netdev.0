From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6]  net: sysfs: ethtool_ops can be NULL
Date: Mon, 26 Oct 2009 09:40:33 -0400
Message-ID: <20091026134033.GD1639@gospo.rdu.redhat.com>
References: <4AE586B5.4030308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbZJZNkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 09:40:43 -0400
Content-Disposition: inline
In-Reply-To: <4AE586B5.4030308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 12:23:33PM +0100, Eric Dumazet wrote:
> commit d519e17e2d01a0ee9abe083019532061b4438065
> (net: export device speed and duplex via sysfs)
> made the wrong assumption that netdev->ethtool_ops was always set.
> 
> This makes possible to crash kernel and let rtnl in locked state.
> 
> modprobe dummy
> ip link set dummy0 up
> (udev runs and crash)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/net-sysfs.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 753c420..89de182 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -139,7 +139,9 @@ static ssize_t show_speed(struct device *dev,
>  	if (!rtnl_trylock())
>  		return restart_syscall();
>  
> -	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> +	if (netif_running(netdev) &&
> +	    netdev->ethtool_ops &&
> +	    netdev->ethtool_ops->get_settings) {
>  		struct ethtool_cmd cmd = { ETHTOOL_GSET };
>  
>  		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))
> @@ -158,7 +160,9 @@ static ssize_t show_duplex(struct device *dev,
>  	if (!rtnl_trylock())
>  		return restart_syscall();
>  
> -	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> +	if (netif_running(netdev) &&
> +	    netdev->ethtool_ops &&
> +	    netdev->ethtool_ops->get_settings) {
>  		struct ethtool_cmd cmd = { ETHTOOL_GSET };
>  
>  		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))

Nice catch, Eric.

Acked-by: Andy Gospodarek <andy@greyhouse.net>

