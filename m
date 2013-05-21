From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 2/2] xen-netfront: split event channels
 feature support
Date: Tue, 21 May 2013 14:39:01 +0100
Message-ID: <519B78F5.5020301@citrix.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com> <1369090931-27306-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3628 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872Ab3EUNjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 09:39:04 -0400
In-Reply-To: <1369090931-27306-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/05/13 00:02, Wei Liu wrote:
> This patch adds a new feature called feature-split-event-channels for
> netfront, enabling it to handle TX and RX events separately.
> 
> If netback does not support this feature, it falls back to use single event
> channel.
[...]
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1503,12 +1528,90 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
>  	return 0;
>  }
>  
> +static int setup_netfront_single(struct netfront_info *info)
> +{
> +	int err;
> +
> +	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
> +	if (err < 0)
> +		goto fail;
> +
> +	err = bind_evtchn_to_irqhandler(info->tx_evtchn,
> +					xennet_interrupt,
> +					0, info->netdev->name, info);
> +	if (err < 0)
> +		goto bind_fail;
> +	info->rx_evtchn = info->tx_evtchn;
> +	info->rx_irq = info->tx_irq = err;
> +	dev_info(&info->xbdev->dev,
> +		 "single event channel, evtchn = %d, irq = %d\n",
> +		 info->tx_evtchn, info->tx_irq);

This message is pointless chatter as the information is available
elsewhere.  Please remove.

> +	dev_info(&info->xbdev->dev,
> +		 "split event channels, tx_evtchn/irq = %d/%d, rx_evtchn/irq = %d/%d",
> +		 info->tx_evtchn, info->tx_irq,
> +		 info->rx_evtchn, info->rx_irq);

Similarly.

Otherwise,

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
