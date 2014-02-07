From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix deadlock in tg3_change_mtu()
Date: Thu, 06 Feb 2014 20:06:47 -0800 (PST)
Message-ID: <20140206.200647.755082106891394503.davem@davemloft.net>
References: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.vrabel@citrix.com, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaBGEGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 23:06:48 -0500
In-Reply-To: <1391724785-13562-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>
Date: Thu, 6 Feb 2014 14:13:05 -0800

> Quoting David Vrabel -
> "5780 cards cannot have jumbo frames and TSO enabled together.  When
> jumbo frames are enabled by setting the MTU, the TSO feature must be
> cleared.  This is done indirectly by calling netdev_update_features()
> which will call tg3_fix_features() to actually clear the flags.
> 
> netdev_update_features() will also trigger a new netlink message for the
> feature change event which will result in a call to tg3_get_stats64()
> which deadlocks on the tg3 lock."
> 
> tg3_set_mtu() does not need to be under the tg3 lock since converting
> the flags to use set_bit(). Move it out to after tg3_netif_stop().
> 
> Reported-by: David Vrabel <david.vrabel@citrix.com>
> Tested-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>

Applied and queued up for -stable, thanks.
