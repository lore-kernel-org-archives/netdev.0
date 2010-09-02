From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Wed, 01 Sep 2010 18:23:18 -0700 (PDT)
Message-ID: <20100901.182318.191170819.davem@davemloft.net>
References: <courier.4C7C99F2.00001F74@fs.ru.acad.bg>
	<20100831192659.GA3093@del.dom.local>
	<1283338251.2556.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, pvp-lsts@fs.uni-ruse.bg,
	herbert@gondor.apana.org.au, rjw@sisk.pl,
	kernel-testers@vger.kernel.org, maciej.rutecki@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47538
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752359Ab0IBBXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:23:02 -0400
In-Reply-To: <1283338251.2556.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Sep 2010 12:50:51 +0200

> [PATCH] gro: fix different skb headrooms
> 
> packets entering GRO might have different headrooms, even for a given
> flow (because of implementation details in drivers, like copybreak).
> We cant force drivers to deliver packets with a fixed headroom.
> 
> 1) fix skb_segment()
> 
> skb_segment() makes the false assumption headrooms of fragments are same
> than the head. When CHECKSUM_PARTIAL is used, this can give csum_start
> errors, and crash later in skb_copy_and_csum_dev()
> 
> 2) allocate a minimal skb for head of frag_list
> 
> skb_gro_receive() uses netdev_alloc_skb(headroom + skb_gro_offset(p)) to
> allocate a fresh skb. This adds NET_SKB_PAD to a padding already
> provided by netdevice, depending on various things, like copybreak.
> 
> Use alloc_skb() to allocate an exact padding, to reduce cache line
> needs:
> NET_SKB_PAD + NET_IP_ALIGN
> 
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=16626
> 
> Many thanks to Plamen Petrov, testing many debugging patches !
> With help of Jarek Poplawski.
> 
> Reported-by: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jarek Poplawski <jarkao2@gmail.com>

Good spotting, applied, thanks!
