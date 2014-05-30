From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: Fix regression caused by efe4208 in
 udp_v6_mcast_next()
Date: Fri, 30 May 2014 15:18:39 -0700 (PDT)
Message-ID: <20140530.151839.1819689526929476760.davem@davemloft.net>
References: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
	<1401395226-10304-2-git-send-email-sven.wegener@stealer.net>
	<1401395855.3645.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sven.wegener@stealer.net, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbaE3WSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:18:42 -0400
In-Reply-To: <1401395855.3645.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 May 2014 13:37:35 -0700

> On Thu, 2014-05-29 at 20:27 +0000, Sven Wegener wrote:
>> Commit efe4208 ("ipv6: make lookups simpler and faster") introduced a
>> regression in udp_v6_mcast_next(), resulting in multicast packets not
>> reaching the destination sockets under certain conditions.
>> 
>> The packet's IPv6 addresses are wrongly compared to the IPv6 addresses
>> from the function's socket argument, which indicates the starting point
>> for looping, instead of the loop variable. If the addresses from the
>> first socket do not match the packet's addresses, no socket in the list
>> will match.
>> 
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: stable@vger.kernel.org # 3.13+
>> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
>> ---
>>  net/ipv6/udp.c | 8 ++++----
>>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> I removed the CC stable@ , as you should not have use it.

I'll apply this to 'net' and queue it up for -stable, thanks.

The next time I merge 'net' into 'net-next' I'll add the second
patch there.

Thanks again.
