From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ne2k: add minimal ethtool setting support
Date: Fri, 18 Jan 2008 15:04:31 -0500
Message-ID: <4791064F.3040901@pobox.com>
References: <20080115154805.69150f76@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39487 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765572AbYARUEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:04:34 -0500
In-Reply-To: <20080115154805.69150f76@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Add minimal ethtool settings support for ne2k driver. This is needed
> for KVM/QEMU environment where ne2k seems to be the simplest stupid
> hardware used.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> 
> --- a/drivers/net/ne2k-pci.c	2008-01-15 11:21:02.000000000 -0800
> +++ b/drivers/net/ne2k-pci.c	2008-01-15 15:43:17.000000000 -0800
> @@ -634,8 +634,21 @@ static void ne2k_pci_get_drvinfo(struct 
>  	strcpy(info->bus_info, pci_name(pci_dev));
>  }
>  
> +static int ne2k_pci_get_settings(struct net_device *dev,
> +				 struct ethtool_cmd *cmd)
> +{
> +	cmd->speed		= SPEED_10;
> +	cmd->duplex		= (ei_status.ne2k_flags & FORCE_FDX)
> +				   ? DUPLEX_FULL : DUPLEX_HALF;
> +	cmd->port		= PORT_TP;
> +	cmd->transceiver	= XCVR_INTERNAL;
> +	cmd->autoneg		= AUTONEG_DISABLE;
> +	return 0;
> +}

It's a little bit /too/ minimal...  the speed is wrong for a large swath 
of 10/100 ne2k chips...

	Jeff



