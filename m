From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3] be2net: Fix to allow get/set of debug
 levels in the firmware.
Date: Mon, 14 May 2012 15:29:19 +0100
Message-ID: <1337005759.2550.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <847bec25-7806-4eaf-8a3e-2411a0c6bba9@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Suresh Redy <suresh.reddy@emulex.com>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63124 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756444Ab2ENO3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 10:29:23 -0400
In-Reply-To: <847bec25-7806-4eaf-8a3e-2411a0c6bba9@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-12 at 09:09 +0530, Somnath Kotur wrote:
[...]
> +static void be_set_msg_level(struct net_device *netdev, u32 level)
> +{
> +	struct be_adapter *adapter = netdev_priv(netdev);
> +
> +	if (lancer_chip(adapter)) {
> +		dev_err(&adapter->pdev->dev, "Operation not supported\n");
> +		return;
> +	}
> +
> +	if (adapter->msg_enable == level)
> +		return;
> +
> +	if (level & NETIF_MSG_HW != adapter->msg_enable & NETIF_MSG_HW)
> +		be_set_fw_log_level(adapter, level & NETIF_MSG_HW ?
> +			       	    FW_LOG_LEVEL_DEFAULT : FW_LOG_LEVEL_FATAL);
[...]

Oh, come on, you can't have actually tested this.  The compiler even
warns you this is probably wrong.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
