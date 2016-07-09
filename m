From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: do not abuse GFP_ATOMIC in
 inet_netconf_notify_devconf()
Date: Sat, 09 Jul 2016 18:12:50 -0400 (EDT)
Message-ID: <20160709.181250.807452024075273359.davem@davemloft.net>
References: <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
	<1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
	<1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masashi.honma@gmail.com, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbcGIWMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 18:12:52 -0400
In-Reply-To: <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jul 2016 05:18:24 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> inet_forward_change() runs with RTNL held.
> We are allowed to sleep if required.
> 
> If we use __in_dev_get_rtnl() instead of __in_dev_get_rcu(),
> we no longer have to use GFP_ATOMIC allocations in
> inet_netconf_notify_devconf(), meaning we are less likely to miss
> notifications under memory pressure, and wont touch precious memory
> reserves either and risk dropping incoming packets.
> 
> inet_netconf_get_devconf() can also use GFP_KERNEL allocation.
> 
> Fixes: edc9e748934c ("rtnl/ipv4: use netconf msg to advertise forwarding status")
> Fixes: 9e5511106f99 ("rtnl/ipv4: add support of RTM_GETNETCONF")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
