From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6_tunnel: ensure to always have a link
 local address
Date: Tue, 20 Aug 2013 23:48:18 -0700 (PDT)
Message-ID: <20130820.234818.2230621827416764963.davem@davemloft.net>
References: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375Ab3HUGsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:48:19 -0400
In-Reply-To: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Aug 2013 12:16:06 +0200

> When an Xin6 tunnel is set up, we check other netdevices to inherit the link-
> local address. If none is available, the interface will not have any link-local
> address. RFC4862 expects that each interface has a link local address.
> 
> Now than this kind of tunnels supports x-netns, it's easy to fall in this case
> (by creating the tunnel in a netns where ethernet interfaces stand and then
> moving it to a other netns where no ethernet interface is available).
> 
> RFC4291, Appendix A suggests two methods: the first is the one currently
> implemented, the second is to generate a unique identifier, so that we can
> always generate the link-local address. Let's use eth_random_addr() to generate
> this interface indentifier.
> 
> I remove completly the previous method, hence for the whole life of the
> interface, the link-local address remains the same (previously, it depends on
> which ethernet interfaces were up when the tunnel interface was set up).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, but this brings up an issue I keep noticing.

We talk about eth_random_addr() and "uniqueness" together all the
time, but the former never implies the latter.

And we're going to run into situations where any conflicts generated
by this random address generater will cause reall failures.

Therefore we'll have to create a system to prevent them.  Probably
using some simple table that keeps track of the addresses we've
generated.
