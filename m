From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: mask vlan prio bits
Date: Thu, 18 Jul 2013 13:05:57 -0700 (PDT)
Message-ID: <20130718.130557.1377061909562984106.davem@davemloft.net>
References: <1374157166.6097.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sesse@google.com, florz@florz.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964850Ab3GRUF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 16:05:59 -0400
In-Reply-To: <1374157166.6097.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Jul 2013 07:19:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 48cc32d38a52d0b68f91a171a8d00531edc6a46e
> ("vlan: don't deliver frames for unknown vlans to protocols")
> Florian made sure we set pkt_type to PACKET_OTHERHOST
> if the vlan id is set and we could find a vlan device for this
> particular id.
> 
> But we also have a problem if prio bits are set.
> 
> Steinar reported an issue on a router receiving IPv6 frames with a
> vlan tag of 4000 (id 0, prio 2), and tunneled into a sit device,
> because skb->vlan_tci is set.
> 
> Forwarded frame is completely corrupted : We can see (8100:4000)
> being inserted in the middle of IPv6 source address :
> 
> 16:48:00.780413 IP6 2001:16d8:8100:4000:ee1c:0:9d9:bc87 >
> 9f94:4d95:2001:67c:29f4::: ICMP6, unknown icmp6 type (0), length 64
>        0x0000:  0000 0029 8000 c7c3 7103 0001 a0ae e651
>        0x0010:  0000 0000 ccce 0b00 0000 0000 1011 1213
>        0x0020:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
>        0x0030:  2425 2627 2829 2a2b 2c2d 2e2f 3031 3233
> 
> It seems we are not really ready to properly cope with this right now.
> 
> We can probably do better in future kernels : 
> vlan_get_ingress_priority() should be a netdev property instead of
> a per vlan_dev one.
> 
> For stable kernels, lets clear vlan_tci to fix the bugs.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
