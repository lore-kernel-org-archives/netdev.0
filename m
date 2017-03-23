From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: Add sysctl to toggle early demux for
 tcp and udp
Date: Wed, 22 Mar 2017 20:36:18 -0700 (PDT)
Message-ID: <20170322.203618.972117086361436133.davem@davemloft.net>
References: <1490234441-19341-1-git-send-email-subashab@codeaurora.org>
        <20170322.194357.531371967824197040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stephen@networkplumber.org, tom@herbertland.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdCWDgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 23:36:22 -0400
In-Reply-To: <20170322.194357.531371967824197040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 22 Mar 2017 19:43:57 -0700 (PDT)

> From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Date: Wed, 22 Mar 2017 20:00:41 -0600
> 
>> Certain system process significant unconnected UDP workload.
>> It would be preferrable to disable UDP early demux for those systems
>> and enable it for TCP only.
>> 
>> By disabling UDP demux, we see these slight gains on an ARM64 system-
>> 782 -> 788Mbps unconnected single stream UDPv4
>> 633 -> 654Mbps unconnected UDPv4 different sources
>> 
>> The performance impact can change based on CPU architecure and cache
>> sizes. There will not much difference seen if entire UDP hash table
>> is in cache.
>> 
>> Both sysctls are enabled by default to preserve existing behavior.
>> 
>> v1->v2: Change function pointer instead of adding conditional as
>> suggested by Stephen.
>> 
>> v2->v3: Read once in callers to avoid issues due to compiler
>> optimizations. Also update commit message with the tests.
>> 
>> v3>v4: Store and use read once result instead of querying pointer
>> again incorrectly.
>> 
>> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, thanks.

This doesn't build with ipv6 as a module:

net/built-in.o: In function `proc_tcp_early_demux':
sysctl_net_ipv4.c:(.text+0x145cfc): undefined reference to `tcp_v6_early_demux_configure'
net/built-in.o: In function `proc_udp_early_demux':
sysctl_net_ipv4.c:(.text+0x145d4c): undefined reference to `udp_v6_early_demux_configure'
Makefile:983: recipe for target 'vmlinux' failed
