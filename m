From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/6] ibmveth: Add ethtool TSO handlers
Date: Fri, 31 Aug 2007 09:14:36 -0400
Message-ID: <46D8143C.9030603@garzik.org>
References: <11873601831813-patch-mail.ibm.com> <200708171416.l7HEGbwx003958@d01av02.pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53203 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664AbXHaNOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:14:38 -0400
In-Reply-To: <200708171416.l7HEGbwx003958@d01av02.pok.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> Add handlers for get_tso and get_ufo to prevent errors being printed
> by ethtool.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6-bjking1/drivers/net/ibmveth.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_get_tso drivers/net/ibmveth.c
> --- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_get_tso	2007-08-08 10:46:28.000000000 -0500
> +++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-08-08 10:46:28.000000000 -0500
> @@ -767,6 +767,8 @@ static const struct ethtool_ops netdev_e
>  	.set_tx_csum		= ibmveth_set_tx_csum,
>  	.get_rx_csum		= ibmveth_get_rx_csum,
>  	.set_rx_csum		= ibmveth_set_rx_csum,
> +	.get_tso			= ethtool_op_get_tso,
> +	.get_ufo			= ethtool_op_get_ufo,

This patch is fine, but I wonder if we shouldn't add some code to 
net/core/ethtool.c along the lines of...

	if (!netdev->ethtool_ops->get_tso)
		ethtool_op_get_tso(args);
	else
		netdev->ethtool_ops->get_tso(args);

Because this certainly seems like desirable behavior across all devices.


