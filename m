From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/3] NetXen: 64-bit memory fixes
Date: Fri, 1 Dec 2006 10:56:13 -0800
Message-ID: <20061201105613.57821d87@freekitty>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, brazilnut@us.ibm.com,
	jeff@garzik.org, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:29130 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1759346AbWLAS6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 13:58:16 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200612011340.kB1DeEhR014690@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't mix whitespace and other fixes at same time.
Add a cleanup patch at beginning or end of series.

Please don't add other things like the driver name this in with bounce buffer
patch. Why the name change from netxen to netxen_nic?


> +/* Bounce buffer index */
> +struct bounce_index {
> +	/* Index of a buffer */
> +	unsigned buffer_index;
> +	/* Offset inside the buffer */
> +	unsigned buffer_offset;
> +};
> +
> +#define IS_BOUNCE 0xcafebb

Magic number? is this safe? why? there is a Documentation
file for these magic-number.txt.

> diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
> index ae180fe..f6ae9fd 100644
> --- a/drivers/net/netxen/netxen_nic_isr.c
> +++ b/drivers/net/netxen/netxen_nic_isr.c
> @@ -68,8 +68,7 @@ struct net_device_stats *netxen_nic_get_
>  void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 portno,
>  				 u32 link)
>  {
> -	struct netxen_port *pport = adapter->port[portno];
> -	struct net_device *netdev = pport->netdev;
> +	struct net_device *netdev = (adapter->port[portno])->netdev;
>  

Parens unnecessary here.

-- 
Stephen Hemminger <shemminger@osdl.org>
