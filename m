From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Wed, 27 Jun 2012 15:34:54 -0700 (PDT)
Message-ID: <20120627.153454.30398632011109264.davem@davemloft.net>
References: <1340788455.26242.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab2F0Wez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:34:55 -0400
In-Reply-To: <1340788455.26242.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 11:14:15 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> DDOS synflood attacks hit badly IP route cache.
> 
> On typical machines, this cache is allowed to hold up to 8 Millions dst
> entries, 256 bytes for each, for a total of 2GB of memory.
> 
> rt_garbage_collect() triggers and tries to cleanup things.
> 
> Eventually route cache is disabled but machine is under fire and might
> OOM and crash.
> 
> This patch exploits the new TCP early demux, to set a nocache
> boolean in case incoming TCP frame is for a not yet ESTABLISHED or
> TIMEWAIT socket.
> 
> This 'nocache' boolean is then used in case dst entry is not found in
> route cache, to create an unhashed dst entry (DST_NOCACHE)
> 
> SYN-cookie-ACK sent use a similar mechanism (ipv4: tcp: dont cache
> output dst for syncookies), so after this patch, a machine is able to
> absorb a DDOS synflood attack without polluting its IP route cache.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
