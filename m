From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: remove phy.h and phy_fixed.h inclusions
Date: Fri, 17 Oct 2014 16:19:18 -0400 (EDT)
Message-ID: <20141017.161918.1724734268959521898.davem@davemloft.net>
References: <1413507355-28837-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbaJQUTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:19:20 -0400
In-Reply-To: <1413507355-28837-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 16 Oct 2014 17:55:55 -0700

> There is no need to include phy.h nor phy_fixed.h when we can use
> forward declarations instead to keep the include chain smaller.
> 
> Doing this unveiled that we were implicitely getting the definitions for
> struct ethtool_eee and struct ethtool_wolinfo, and that net/dsa/slave.c
> was missing an include of phy_fixed.h.
> 
> Fixes: ec9436baedb6 ("net: dsa: allow drivers to do link adjustment")
> Fixes: ce31b31c68e7 ("net: dsa: allow updating fixed PHY link information")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Please, don't do this.

Get the definitions from the header file that provides them.

The only situation where forward declarations done by hand like this
make sense is when there is absolutely no way to avoid looping header
includes.

For example in A.h you want to provide a function that takes a pointer
to foo, but foo is defined B.h which includes A.h first.

Thanks.
