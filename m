From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 09:33:49 -0700
Message-ID: <20060525093349.3f42220a@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.33.0605250347050.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32657 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030253AbWEYQeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 12:34:20 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250347050.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor nits.

On Thu, 25 May 2006 03:48:38 -0700 (PDT)
"Linsys Contractor Amit S. Kale" <amitkale@unminc.com> wrote:

> +/*
> + * Note: This change will be reflected in all the four ports as there is 
> + * only one common adapter.
> + */
> +static int
> +netxen_nic_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
> +{
> +	return 0;
> +}

Why not just return have no hook if you can't set parameters.  Then the ioctl
will return not supported -EOPNOTSUPP

>
> +static u32 netxen_nic_get_rx_csum(struct net_device *dev)
> +{
> +	return (dev->features & NETIF_F_HW_CSUM);
> +}


You got receive and transmit checksum confused.  You need to separate
checksumming on output (dev->features & NETIF_F_HW_CSUM) versus receive
checksum (controlled by hardware and usually a flag in private data structure).

> +static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
> +{
> +	if (data)
> +		dev->features |= NETIF_F_HW_CSUM;
> +	else
> +		dev->features &= (~NETIF_F_HW_CSUM);
> +
> +	if (netif_running(dev)) {
> +		dev->stop(dev);	/* verify */
> +		dev->open(dev);

What if open fail fails?  Then you have an "interesting" recovery
situation.  
> +	}
> +	return 0;
> +}
> 
