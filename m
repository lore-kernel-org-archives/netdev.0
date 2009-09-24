From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] inet_peer: Optimize inet_getid()
Date: Thu, 24 Sep 2009 12:30:20 -0700
Message-ID: <20090924123020.59a2ee6e@s6510>
References: <4ABBC2D8.2040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57559 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbZIXTaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 15:30:24 -0400
In-Reply-To: <4ABBC2D8.2040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2009 21:04:56 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> While investigating for network latencies, I found inet_getid() was a contention point
> for some workloads.
> 
> Fix is straightforward, using cmpxchg() instead of
> a spin_lock_bh()/spin_unlock_bh() pair on a central lock.
> 
> Another possibility was to use an atomic_t and atomic_add_return() but
> the size of struct inet_peer object would had doubled on x86_64 because of
> SLAB_HWCACHE_ALIGN constraint.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I thought cmpxchg was not available on all architectures.
