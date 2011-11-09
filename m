From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: reduce percpu needs for icmpmsg mibs
Date: Wed, 09 Nov 2011 16:04:38 -0500 (EST)
Message-ID: <20111109.160438.1236405221658994935.davem@davemloft.net>
References: <1320793483.26025.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075Ab1KIVEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 16:04:41 -0500
In-Reply-To: <1320793483.26025.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Nov 2011 00:04:43 +0100

> Reading /proc/net/snmp on a machine with a lot of cpus is very expensive
> (can be ~88000 us).
> 
> This is because ICMPMSG MIB uses 4096 bytes per cpu, and folding values
> for all possible cpus can read 16 Mbytes of memory.
> 
> ICMP messages are not considered as fast path on a typical server, and
> eventually few cpus handle them anyway. We can afford an atomic
> operation instead of using percpu data.
> 
> This saves 4096 bytes per cpu and per network namespace.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> If this patch is accepted, I'll submit the IPv6 part as well.

Looks good, applied, thanks Eric.
