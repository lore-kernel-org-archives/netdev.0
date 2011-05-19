From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes
Date: Thu, 19 May 2011 16:19:07 -0400 (EDT)
Message-ID: <20110519.161907.1750862041337015528.davem@davemloft.net>
References: <1305787158.3019.12.camel@edumazet-laptop>
	<1305788113.3019.19.camel@edumazet-laptop>
	<1305803663.3028.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1ESUTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:19:11 -0400
In-Reply-To: <1305803663.3028.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 May 2011 13:14:23 +0200

> [PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes.
> 
> ipv6 has per device ICMP SNMP counters, taking too much space because
> they use percpu storage.
> 
> needed size per device is : 
> (512+4)*sizeof(long)*number_of_possible_cpus*2 
> 
> On a 32bit kernel, 16 possible cpus, this wastes more than 64kbytes of
> memory per ipv6 enabled network device, taken in vmalloc pool.
> 
> Since ICMP messages are rare, just use shared counters (atomic_long_t)
> 
> Per network space ICMP counters are still using percpu memory, we might
> also convert them to shared counters in a future patch.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
