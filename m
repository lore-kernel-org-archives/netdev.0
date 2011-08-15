From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()
Date: Sun, 14 Aug 2011 23:39:32 -0700 (PDT)
Message-ID: <20110814.233932.2301816716849474809.davem@davemloft.net>
References: <20110810.231318.959972077845910551.davem@davemloft.net>
	<1313044387.3066.8.camel@edumazet-laptop>
	<1313129310.2669.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab1HOGjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 02:39:36 -0400
In-Reply-To: <1313129310.2669.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Aug 2011 08:08:30 +0200

> [PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()
> 
> LIMIT_NETDEBUG allows the admin to disable some warning messages :
> echo 0 > /proc/sys/net/core/warnings
> 
> Use it to avoid filling syslog on busy servers.
> 
> Based on a previous patch from Tom Herbert
> 
> Factorize syn_flood_warning() IPv4/IPv6 implementations
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>

This is a big hammer with no granularity.

I have to give up other potentially interesting log messages (open
request drops, IP frag out-of-memory, etc.) just to get this one to go
away.

I still stand by my original suggestion, print unconditionally and
only once, and also add the statistics counters.
