From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: kill sk_dst_lock
Date: Wed, 02 Dec 2015 23:42:16 -0500 (EST)
Message-ID: <20151202.234216.1113392733011218992.davem@davemloft.net>
References: <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448854142.24696.109.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758149AbbLCEmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 23:42:18 -0500
In-Reply-To: <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2015 08:35:15 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing the np->opt RCU conversion, I found that UDP/IPv6 was
> using a mixture of xchg() and sk_dst_lock to protect concurrent changes
> to sk->sk_dst_cache, leading to possible corruptions and crashes.
> 
> ip6_sk_dst_lookup_flow() uses sk_dst_check() anyway, so the simplest
> way to fix the mess is to remove sk_dst_lock completely, as we did for
> IPv4.
> 
> __ip6_dst_store() and ip6_dst_store() share same implementation.
> 
> sk_setup_caps() being called with socket lock being held or not,
> we have to use sk_dst_set() instead of __sk_dst_set()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Please update the commit log message with the details you
provided in a reply to this thread.

Thanks.
