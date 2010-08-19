From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ehea: Allocate stats buffer with GFP_KERNEL
Date: Thu, 19 Aug 2010 00:53:23 -0700 (PDT)
Message-ID: <20100819.005323.73677219.davem@davemloft.net>
References: <20100701.224805.221588889.davem@davemloft.net>
	<1282140652.2194.90.camel@edumazet-laptop>
	<29190.1282153781@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, brking@linux.vnet.ibm.com,
	ossthema@de.ibm.com, osstklei@de.ibm.com, raisch@de.ibm.com,
	netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750896Ab0HSHxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:53:04 -0400
In-Reply-To: <29190.1282153781@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 18 Aug 2010 10:49:41 -0700

> 	So, the real question is whether the ndo_get_stats* functions
> are permitted to sleep.  If they are, then bonding and netstat_show both
> need to change.  If not, then ehea needs to change.  Ehea is probably
> not alone in this; I poked around a bit, and it looks like mlx4 may also
> sleep in ndo_get_stats.

They really can't currently.... so EHEA will need to be changed
such that it can do stats fetching atomically.

In the long term, we could allow this.

The netstat_stat function should be RCU'able.  And something
similar, I suppose, should be possible on the bonding side.

But as it stands EHEA has to be fixed and can't stay as-is.
