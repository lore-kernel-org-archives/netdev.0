From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix ecmp lookup on forwarding path
Date: Thu, 13 Jun 2013 17:38:29 -0700 (PDT)
Message-ID: <20130613.173829.683328203745717078.davem@davemloft.net>
References: <1371132295-5620-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhi.ding@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab3FNAia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:38:30 -0400
In-Reply-To: <1371132295-5620-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 13 Jun 2013 16:04:55 +0200

> From: dingzhi <zhi.ding@6wind.com>
> 
> There is no reason to skip ECMP lookup when oif is specified. For example, when
> a packet is forwarded, the input interface is specified.
> 
> Signed-off-by: dingzhi <zhi.ding@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

There is no way this is valid.

The multipath code makes no attempt to choose a route that goes via
the interface that matches the one the user asked for in the flow key.

We must absolutely respect the OIF in the flow key during the route
lookup, this means no multipath until that code is changed to strictly
respect the OIF in the lookup key.

Otherwise what's the point of the OIF if you're going to pick a route
that doesn't match it?

I'm not apply this patch, sorry.
