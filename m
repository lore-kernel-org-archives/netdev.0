From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Provide CPU port statistics to
 master netdev
Date: Thu, 28 Apr 2016 17:16:36 -0400 (EDT)
Message-ID: <20160428.171636.1239468738278228965.davem@davemloft.net>
References: <1461782714-13471-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcD1VQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:16:38 -0400
In-Reply-To: <1461782714-13471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 27 Apr 2016 11:45:14 -0700

> This patch overloads the DSA master netdev, aka CPU Ethernet MAC to also
> include switch-side statistics, which is useful for debugging purposes,
> when the switch is not properly connected to the Ethernet MAC (duplex
> mismatch, (RG)MII electrical issues etc.).
> 
> We accomplish this by retaining the original copy of the master netdev's
> ethtool_ops, and just overload the 3 operations we care about:
> get_sset_count, get_strings and get_ethtool_stats so as to intercept
> these calls and call into the original master_netdev ethtool_ops, plus
> our own.
> 
> We take this approach as opposed to providing a set of DSA helper
> functions that would retrive the CPU port's statistics, because the
> entire purpose of DSA is to allow unmodified Ethernet MAC drivers to be
> used as CPU conduit interfaces, therefore, statistics overlay in such
> drivers would simply not scale.
> 
> The new ethtool -S <iface> output would therefore look like this now:
> <iface> statistics
> p<2 digits cpu port number>_<switch MIB counter names>
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
