From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: sit: update mtu check to take care of gso packets
Date: Wed, 18 Dec 2013 17:57:02 -0500 (EST)
Message-ID: <20131218.175702.1462184363404956747.davem@davemloft.net>
References: <52AB322B.7030802@redhat.com>
	<1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3LRW5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:57:04 -0500
In-Reply-To: <1387204283.19078.240.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Dec 2013 06:31:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing my changes for TSO support in SIT devices,
> I was using sit0 tunnel which appears to include nopmtudisc flag.
> 
> But using :
> 
> ip tun add sittun mode sit remote $REMOTE_IPV4 local $LOCAL_IPV4 \
>    dev $IFACE
> 
> We get a tunnel which rejects too long packets because of the mtu check
> which is not yet GSO aware.
> 
> erd:~# ip tunnel
> sittun: ipv6/ip  remote 10.246.17.84  local 10.246.17.83  ttl inherit  6rd-prefix 2002::/16 
> sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16 
> 
> This patch is based on an excellent report from
> Michal Shmidt.
> 
> In the future, we probably want to extend the MTU check to do the
> right thing for GSO packets...
> 
> Fixes: ("61c1db7fae21 ipv6: sit: add GSO/TSO support")
> Reported-by: Michal Schmidt <mschmidt@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
