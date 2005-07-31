From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Sat, 30 Jul 2005 20:51:05 -0700 (PDT)
Message-ID: <20050730.205105.125871032.davem@davemloft.net>
References: <17130.16951.581026.863431@robur.slu.se>
	<42EA6202.703@hp.com>
	<42EA6E0F.8060705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@oss.sgi.com, davem@redhat.com,
        Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42EA6E0F.8060705@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 29 Jul 2005 19:57:35 +0200

> nm -v /usr/src/linux/vmlinux | grep -5 rt_cache_stat
> 
> ffffffff804c6a80 b rover.5
> ffffffff804c6a88 b last_gc.2
> ffffffff804c6a90 b rover.3
> ffffffff804c6a94 b equilibrium.4
> ffffffff804c6a98 b ip_fallback_id.7
> ffffffff804c6aa0 B rt_cache_stat
> ffffffff804c6aa8 b ip_rt_max_size
> ffffffff804c6aac b ip_rt_debug
> ffffffff804c6ab0 b rt_deadline
> 
> So rt_cache_stat (which is a read only pointer) is in the middle of a hot cache line (some parts of it are written over and over), that 
> probably ping pong between CPUS.

One cure for this would be to declare it as "__read_mostly", that
should help a lot.  But it's not the best idea, I think.

Instead, we can do away with the pointer and use DECLARE_PERCPU() and
__get_cpu_var() for rt_cache_stat.  That would emit the most efficient
code on every architecture.
