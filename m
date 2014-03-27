From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: dummy: make use of multi-queues
Date: Wed, 26 Mar 2014 19:51:02 -0700
Message-ID: <1395888662.12610.278.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395880676-4472-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:49975 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169AbaC0CvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 22:51:04 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so2834380pbb.28
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 19:51:03 -0700 (PDT)
In-Reply-To: <1395880676-4472-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 01:37 +0100, Daniel Borkmann wrote:
> Quite often it can be useful to just use the dummy device as a blackhole
> sink for skbs, e.g. for packet sockets or pktgen tests. Therefore, make
> use of multiqueues, so that we can simulate for that. trafgen mmap/TX_RING
> example against dummy device with config foo: { fill(0xff, 64) } results
> in the following performance improvements on an ordinary Core i7/2.80GHz
> as we don't need to take a single queue/lock anymore:
> 
> Before:
> 
>  Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):
> 
>    160,975,944,159 instructions:k            #    0.55  insns per cycle          ( +-  0.09% )
>    293,319,390,278 cycles:k                  #    0.000 GHz                      ( +-  0.35% )
>        192,501,104 branch-misses:k                                               ( +-  1.63% )
>                831 context-switches:k                                            ( +-  9.18% )
>                  7 cpu-migrations:k                                              ( +-  7.40% )
>             69,382 cache-misses:k            #    0.010 % of all cache refs      ( +-  2.18% )
>        671,552,021 cache-references:k                                            ( +-  1.29% )
> 
>       22.856401569 seconds time elapsed                                          ( +-  0.33% )
> 
> After:
> 
>  Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):
> 
>    138,669,108,882 instructions:k            #    0.92  insns per cycle          ( +-  0.02% )
>    151,222,621,155 cycles:k                  #    0.000 GHz                      ( +-  0.11% )
>         57,667,395 branch-misses:k                                               ( +-  6.15% )
>                400 context-switches:k                                            ( +-  2.73% )
>                  6 cpu-migrations:k                                              ( +-  7.51% )
>             67,414 cache-misses:k            #    0.075 % of all cache refs      ( +-  1.64% )
>         90,479,875 cache-references:k                                            ( +-  0.75% )
> 
>       12.080331543 seconds time elapsed                                          ( +-  0.13% )

 

Its a LLTX device, so it looks there is no bottleneck in this driver,
but in the caller ;)

If you need many channels, you can setup as many dummy devices you want.
