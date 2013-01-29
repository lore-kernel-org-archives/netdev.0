From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 17:54:11 +0000
Message-ID: <1359482051.4144.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25133 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab3A2RyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 12:54:14 -0500
In-Reply-To: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-25 at 15:54 -0500, Neil Horman wrote:
> vmxnet3 fails to set netif_carrier_off on probe, meaning that when an interface
> is opened the __LINK_STATE_NOCARRIER bit is already cleared, and so
> /sys/class/net/<ifname>/operstate remains in the unknown state.  Correct this by
> setting netif_carrier_off on probe, like other drivers do.
> 
> Also, while we're at it, lets remove the netif_carrier_ok checks from the
> link_state_update function, as that check is atomically contained within the
> netif_carrier_[on|off] functions anyway
> 
> Tested successfully by myself
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: "VMware, Inc." <pv-drivers@vmware.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index b1c90f8..66c26a9 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
[...]
> @@ -3067,6 +3065,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
>  		goto err_register;
>  	}
>  
> +	netif_carrier_off(netdev);
>  	vmxnet3_check_link(adapter, false);
>  	return 0;
>  

You should do this before calling register_netdev(), otherwise the link
state change can race with vmxnet3_open().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
