From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Fri, 29 Jul 2005 11:25:21 -0700
Message-ID: <42EA7491.1010207@hp.com>
References: <42E8FF24.9070009@cosmosbay.com>	<20050728.123922.126777020.davem@davemloft.net>	<42E94680.8060309@cosmosbay.com>	<20050728.135826.63129319.davem@davemloft.net>	<42E94D11.4090002@cosmosbay.com>	<17130.16951.581026.863431@robur.slu.se> <42EA6202.703@hp.com> <42EA6E0F.8060705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42EA6E0F.8060705@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> oprofile on AMD64 can gather lots of data, DATA_CACHE_MISSES for example...
> 
> But I think I know what happens...
> 
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
> So rt_cache_stat (which is a read only pointer) is in the middle of a 
> hot cache line (some parts of it are written over and over), that 
> probably ping pong between CPUS.
> 
> Time to provide a patch to carefully place all the static data from 
> net/ipv4/route.c into 2 parts : mostly readonly, and others... :)

Which of course begs the question - what cache line size should be ass-u-me-d 
when blocking these things?  I'll put-forth 128 bytes.

rick jones
