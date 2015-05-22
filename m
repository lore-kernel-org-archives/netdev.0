From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ipv6: reject locally assigned nexthop addresses
Date: Thu, 21 May 2015 23:24:05 -0400 (EDT)
Message-ID: <20150521.232405.2190506424761589353.davem@davemloft.net>
References: <1432160741-3588-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbbEVDYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:24:07 -0400
In-Reply-To: <1432160741-3588-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 21 May 2015 00:25:41 +0200

> ip -6 addr add dead::1/128 dev eth0
> sleep 5
> ip -6 route add default via dead::1/128
> -> fails
> ip -6 addr add dead::1/128 dev eth0
> ip -6 route add default via dead::1/128
> -> succeeds
> 
> reason is that if (nonsensensical) route above is added,
> dead::1 is still subject to DAD, so the route lookup will
> pick eth0 as outdev due to the prefix route that is added before
> DAD work is started.
> 
> Add explicit test that checks if nexthop gateway is a local address.
> 
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1167969
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to net-next, thanks.
