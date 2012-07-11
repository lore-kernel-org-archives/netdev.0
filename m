From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 21:02:21 -0700 (PDT)
Message-ID: <20120710.210221.559183284956265274.davem@davemloft.net>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab2GKECV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:02:21 -0400
In-Reply-To: <1341978558.3265.6609.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Jul 2012 05:49:18 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
> use long words to reduce number of instructions for free.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Joe Perches <joe@perches.com>

Maybe we can even be sure that they are 64-bit aligned too?

If there's an embedded u64 in the in6_addr union, they really should
be.

It can't even be an issue in the protocol headers, because in the
socket demux we read the two 32-bit ipv4 addresses in the packet
header as one 64-bit chunk already.
