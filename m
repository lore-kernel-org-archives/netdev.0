From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool
 support
Date: Tue, 26 Apr 2016 16:03:01 -0400 (EDT)
Message-ID: <20160426.160301.938979848864279754.davem@davemloft.net>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbcDZUDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:03:03 -0400
In-Reply-To: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Sun, 24 Apr 2016 22:51:45 +0300

> Changes from V0:
> 	- Dropped: net/mlx5e: Disable link up on INIT HCA command
> 	  Due to Ido's and Or's requests we will submit this patch to net and will need it for -stable.
> 	- Rebased to: 11afbff86168 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next")
> 
> This series is centralized around extending and improving mlx5 ethernet driver ethtool 
> support. We've done some code refactoring for ethtool statistics reporting, making it 
> more scalable and robust, now each reported ethtool counter belongs to a group and has
> its own descriptor within that group, the descriptor holds the counter name and offset
> in memory in that group memory block.
> 
> Added new counters:
> 	- Reporting more error and drop counter in ifconig/ip tool.
> 	- Per priority pause and traffic counter in ethtool.
> 	- link down events counter in ethtool.
>   
> Set features handling was also refactored a little bit to be more resilient and generic, 
> now setting more than one feature will not stop on the first failed one, but instead
> it will try to continue setting others. We made it generic to make it simpler for adding
> more features support, it is now done easily by only introducing a handler function of 
> the new supported netdev feature, and let the generic handler do the job.
> 
> New netdev features and ethtool support:
> 	- Netdev feature RXALL, set on/off FCS check offload.
> 	- Netdev feature HW_VLAN_CTAG_RX, set on/off rx-vlan stripping offload.
> 	- Ethtool interface identify.
> 	- Ethtool dump module EEPROM.

Series applied.

Be careful about what feature update semantics you implement.  If you get a request
to change multiple feature bits, and even one of them cannot be done, the entire
update operation should fail and the bits should revert to what they were before
the request.

Is that how the code behaves now?
