From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/forcedeth: refactor wol support to make it
 easier to add more wol modes
Date: Sun, 13 Mar 2016 22:14:34 -0400 (EDT)
Message-ID: <20160313.221434.1980290565680430002.davem@davemloft.net>
References: <1457621884-2479-1-git-send-email-git@karolherbst.de>
	<1457621884-2479-2-git-send-email-git@karolherbst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: git@karolherbst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbcCNCOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:14:37 -0400
In-Reply-To: <1457621884-2479-2-git-send-email-git@karolherbst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karol Herbst <git@karolherbst.de>
Date: Thu, 10 Mar 2016 15:58:03 +0100

> @@ -4218,8 +4219,9 @@ static void nv_get_wol(struct net_device *dev, struct ethtool_wolinfo *wolinfo)
>  	wolinfo->supported = WAKE_MAGIC;
>  
>  	spin_lock_irq(&np->lock);
> -	if (np->wolenabled)
> -		wolinfo->wolopts = WAKE_MAGIC;
> +	wolinfo->wolopts = 0;
> +	if (np->wolenabled & WAKE_MAGIC)
> +		wolinfo->wolopts |= WAKE_MAGIC;
>  	spin_unlock_irq(&np->lock);
>  }
>  

When I see a change like this I can see you don't understand the
contract that exists between the ethtool core layer and your
driver.

The command info struct, in this case 'wolinfo' passed to you is
zero'd out, always.

Therefore the part of the change explicitly clearing out
wolinfo->wolopts is completely unnecessary and needs to be removed.

Thanks.
