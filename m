From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet_peer: Optimize inet_getid()
Date: Mon, 05 Oct 2009 00:08:18 -0700 (PDT)
Message-ID: <20091005.000818.95127796.davem@davemloft.net>
References: <4ABBC2D8.2040901@gmail.com>
	<20090924123020.59a2ee6e@s6510>
	<4ABBDA45.2040109@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758229AbZJEHIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:08:23 -0400
In-Reply-To: <4ABBDA45.2040109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Sep 2009 22:44:53 +0200

> [PATCH] inet_peer: Optimize inet_getid()
> 
> While investigating for network latencies, I found inet_getid() was a contention point
> for some workloads.
> 
> If __HAVE_ARCH_CMPXCHG is defined, we can use cmpxchg() instead of
> a spin_lock_bh()/spin_unlock_bh() pair on a central lock.
> 
> On other arches, we can use an atomic_t instead of a u16,
> and atomic_add_return(). This might grow memory usage a bit, unless
> someone invents atomic16_t :)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I can't apply this, it's going to break the build on some
architectures.

For example, sparc64 only supports cmpxchg on u32 and u64
objects, but you're trying to use it on a u16 here.
