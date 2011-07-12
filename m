From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] net: introduce
 __netdev_alloc_skb_ip_align
Date: Mon, 11 Jul 2011 19:32:23 -0700 (PDT)
Message-ID: <20110711.193223.1071104458616510178.davem@davemloft.net>
References: <1310421164.2860.21.camel@edumazet-laptop>
	<1310425028.2707.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab1GLCcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 22:32:32 -0400
In-Reply-To: <1310425028.2707.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 11 Jul 2011 23:57:08 +0100

> On Mon, 2011-07-11 at 23:52 +0200, Eric Dumazet wrote:
>> RX rings should use GFP_KERNEL allocations if possible, add
>> __netdev_alloc_skb_ip_align() helper to ease this.
> [...]
> 
> When it is possible, other than when starting an interface?  RX refill
> normally has to be done in NAPI context or at least synchronised with
> NAPI, so GFP_ATOMIC is required.  Not sure how much point there is in
> making a special case for the initial fill.

There is a point, because if this init case fails you lose the
interface entirely.

Whereas the other cases only cause the loss of a few packets.
