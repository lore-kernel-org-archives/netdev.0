From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipmr/ip6mr: prevent out-of-bounds vif_table access
Date: Fri, 26 Mar 2010 11:11:45 -0700 (PDT)
Message-ID: <20100326.111145.76087355.davem@davemloft.net>
References: <4BAC823F.8050409@dev.6wind.com>
	<20100326.095137.165317348.davem@davemloft.net>
	<4BACECA6.2050506@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753056Ab0CZSLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:11:22 -0400
In-Reply-To: <4BACECA6.2050506@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Fri, 26 Mar 2010 18:19:34 +0100

> yes, but I think that it is not enough, ip[6]mr_mfc_add() is only
> called via setsockopt().
> 
> When a multicast packet arrived in ip6_mr_input(), if there is no
> cache ip6mr_cache_unresolved() will be called and this function will
> add an entry with parent == 65535.
> 
> And the second problem is that when a vif is removed, no cleanup is
> made in cache entry. Hence, we can have a cache entry which points to
> an invalid vif (dev is set ot NULL).

Ok, I'll take another look at your patch, thanks for
explaining.
