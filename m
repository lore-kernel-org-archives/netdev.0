From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/4] ipv6: datagram: Update dst cache of a
 connected udp sk during pmtu update
Date: Thu, 14 Apr 2016 16:45:09 -0400 (EDT)
Message-ID: <20160414.164509.673278059146942229.davem@davemloft.net>
References: <1460413777-177662-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	edumazet@google.com, weiwan@google.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbcDNUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 16:45:12 -0400
In-Reply-To: <1460413777-177662-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 11 Apr 2016 15:29:33 -0700

> v2:
> ~ Protect __sk_dst_get() operations with rcu_read_lock in
>   release_cb() because another thread may do ip6_dst_store()
>   for a udp sk without taking the sk lock (e.g. in sendmsg).
> ~ Do a ipv6_addr_v4mapped(&sk->sk_v6_daddr) check before
>   calling ip6_datagram_dst_update() in patch 3 and 4.  It is
>   similar to how __ip6_datagram_connect handles it.
> ~ One fix in ip6_datagram_dst_update() in patch 2.  It needs
>   to check (np->flow_label & IPV6_FLOWLABEL_MASK) before
>   doing fl6_sock_lookup.  I was confused with the naming
>   of IPV6_FLOWLABEL_MASK and IPV6_FLOWINFO_MASK.
> ~ Check dst->obsolete just on the safe side, although I think it
>   should at least have DST_OBSOLETE_FORCE_CHK by now.
> ~ Add Fixes tag to patch 3 and 4
> ~ Add some points from the previous discussion about holding
>   sk lock to the commit message in patch 3.
> 
> v1:
> There is a case in connected UDP socket such that
> getsockopt(IPV6_MTU) will return a stale MTU value. The reproducible
> sequence could be the following:
> 1. Create a connected UDP socket
> 2. Send some datagrams out
> 3. Receive a ICMPV6_PKT_TOOBIG
> 4. No new outgoing datagrams to trigger the sk_dst_check()
>    logic to update the sk->sk_dst_cache.
> 5. getsockopt(IPV6_MTU) returns the mtu from the invalid
>    sk->sk_dst_cache instead of the newly created RTF_CACHE clone.
> 
> Patch 1 and 2 are the prep work.
> Patch 3 and 4 are the fixes.

Series applied, thanks Martin.
