From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 2/3] igb: add support for VF Transmit rate limit
 using iproute2
Date: Fri, 28 Jan 2011 16:38:17 -0800 (PST)
Message-ID: <20110128.163817.193721063.davem@davemloft.net>
References: <1296217779-30133-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296217779-30133-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lior.levy@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44170
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754087Ab1A2Ahm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 19:37:42 -0500
In-Reply-To: <1296217779-30133-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 28 Jan 2011 04:29:38 -0800

> +	if (tx_rate != 0)
> +		dev_info(&adapter->pdev->dev,
> +		         "Setting Transmit rate of %d Mbps for VF %d\n",
> +		         tx_rate, vf);
> +	else
> +		dev_info(&adapter->pdev->dev,
> +		         "Transmit rate limit for VF %d is disabled\n", vf);

If you're going to print this, use netdev_info(netdev, ...).

But I think you shouldn't be logging anything at all.

No other ethtool operation logs what it did except in extremely
exceptional error conditions.  And there is nothing special
about this VF rate limiting ethtool operation to justify these
extraneous logging messages.

If people want to know if the VF is rate limited, and by how much,
then can query the configuration using ethtool.
