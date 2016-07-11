From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] rtnl: Add GFP flag argument to
 rtnl_unicast()
Date: Mon, 11 Jul 2016 13:01:47 -0700 (PDT)
Message-ID: <20160711.130147.2231877907183030717.davem@davemloft.net>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
	<1468036744-3964-1-git-send-email-masashi.honma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: masashi.honma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbcGKUBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:01:48 -0400
In-Reply-To: <1468036744-3964-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masashi Honma <masashi.honma@gmail.com>
Date: Sat,  9 Jul 2016 12:59:04 +0900

> This commit extends rtnl_unicast() to specify GFP flags.
> 
> This commit depends on Eric Dumazet's commits below.
> 	ipv4: do not abuse GFP_ATOMIC in inet_netconf_notify_devconf()
> 	ipv6: do not abuse GFP_ATOMIC in inet6_netconf_notify_devconf()
> 
> Signed-off-by: Masashi Honma <masashi.honma@gmail.com>

The code is correct and optimal as-is.  There is no gain to your
changes.  gfp_any() will do the right thing.

In fact, your change makes the code more error prone because if any
of these code paths get moved into an atomic context they will break
unless somone remembers to also fix up the GFP flags.

Meanwhile with the existing use of gfp_any() it will work
transparently in such a situation.

I'm not applying this.
