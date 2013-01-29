From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 08:36:26 +0100
Message-ID: <20130129073626.GB18272@localhost.localdomain>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>
 <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 29, 2013 at 01:42:25AM +0530, Mugunthan V N wrote:
> @@ -947,6 +1042,10 @@ static const struct net_device_ops cpsw_netdev_ops = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= cpsw_ndo_poll_controller,
>  #endif
> +#ifdef VLAN_SUPPORT
> +	.ndo_vlan_rx_add_vid	= cpsw_ndo_vlan_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid	= cpsw_ndo_vlan_rx_kill_vid,
> +#endif

These are not compile time conditionals in net_device_ops, so I wonder
(after reading Felipe's comments) whether you can simply keep the VLAN
code always present.

As long as the driver still compiles and loads, when VLAN is missing
from the stack, then I don't see why you can't just leave it in,
without all the ifdefs.

Thanks,
Richard
