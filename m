From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/5] ixgbe: Add support for the new
 ethtool n-tuple programming interface
Date: Fri, 08 Jan 2010 00:26:42 -0800 (PST)
Message-ID: <20100108.002642.221825262.davem@davemloft.net>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	<20100107044952.28605.35232.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com, deri@ntop.org,
	joseph.gasparakis@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753486Ab0AHI0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:26:34 -0500
In-Reply-To: <20100107044952.28605.35232.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 Jan 2010 20:49:53 -0800

> +	/*
> +	 * Don't allow programming if we're not in perfect filter mode, or
> +	 * if the action is a queue greater than the number of online Tx
> +	 * queues.
> +	 */
> +	if ((!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) ||
> +	    (fs.action >= adapter->num_tx_queues))
> +		return -EINVAL;

This is yet another argument for making the perfect filter mode
control an ethtool setting, why should the user have to reload the
module just to get that boolean setting fixed up when they want to
load filters?
