From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: protects md5sig_info with RCU
Date: Wed, 01 Feb 2012 02:18:08 -0500 (EST)
Message-ID: <20120201.021808.298882655874661806.davem@davemloft.net>
References: <1328057424-11962-1-git-send-email-shawn.lu@ericsson.com>
	<1328057424-11962-2-git-send-email-shawn.lu@ericsson.com>
	<1328071540.2617.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab2BAHSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 02:18:14 -0500
In-Reply-To: <1328071540.2617.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Feb 2012 05:45:40 +0100

> This patch makes sure we use appropriate memory barriers before
> publishing tp->md5sig_info, allowing tcp_md5_do_lookup() being used from
> tcp_v4_send_reset() without holding socket lock (upcoming patch from
> Shawn Lu)
> 
> Note we also need to respect rcu grace period before its freeing, since
> we can free socket without this grace period thanks to
> SLAB_DESTROY_BY_RCU
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
