From: Mike Galbraith <bitbucket@online.de>
Subject: Re: query: localhost - 794ed393b clips hefty load tbench, does it
 matter?
Date: Thu, 28 Feb 2013 22:06:06 +0100
Message-ID: <1362085566.4560.76.camel@marge.simpson.net>
References: <1362055757.4460.236.camel@marge.simpson.net>
	 <1362068018.15793.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50977 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760454Ab3B1VGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 16:06:09 -0500
In-Reply-To: <1362068018.15793.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 08:13 -0800, Eric Dumazet wrote: 
> On Thu, 2013-02-28 at 13:49 +0100, Mike Galbraith wrote:
> > Greetings network wizards,
> > 
> > I was testing a 64 core box after 3.0-stable update, and noticed
> > $subject.
> > 
> > vogelweide:~/:[0]# numactl --hardware
> > available: 1 nodes (0)
> > node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
> > node 0 size: 8181 MB
> > node 0 free: 7353 MB
> > node distances:
> > node   0 
> >   0:  10
> > 
> > Sob, poor thing.  Anyway, that's the box in case it matters.
> > 
> > Without 94ed393b. 
> > 
> > vogelweide:~/:[0]# for i in 1 2 4 8 16 32 64 128 256 512; do tbench.sh $i 10 2>&1|grep Throughput; done
> > Throughput 288.784 MB/sec 1 procs
> > Throughput 559.937 MB/sec 2 procs
> > Throughput 1068.75 MB/sec 4 procs
> > Throughput 2159.04 MB/sec 8 procs
> > Throughput 4193.75 MB/sec 16 procs
> > Throughput 7662.24 MB/sec 32 procs
> > Throughput 9034.49 MB/sec 64 procs
> > Throughput 9045.9 MB/sec 128 procs
> > Throughput 9077.55 MB/sec 256 procs
> > Throughput 8907.48 MB/sec 512 procs
> > 
> > With.
> > 
> > vogelweide:~/:[0]# for i in 1 2 4 8 16 32 64 128 256 512; do tbench.sh $i 10 2>&1|grep Throughput; done
> > Throughput 288.833 MB/sec 1 procs
> > Throughput 520.87 MB/sec 2 procs
> > Throughput 937.758 MB/sec 4 procs
> > Throughput 1563.3 MB/sec 8 procs
> > Throughput 1775.14 MB/sec 16 procs
> > Throughput 1406.55 MB/sec 32 procs
> > Throughput 1448.77 MB/sec 64 procs
> > Throughput 1468.92 MB/sec 128 procs
> > Throughput 1525.35 MB/sec 256 procs
> > Throughput 1713.54 MB/sec 512 procs
> > 
> > I'm wondering if this could cause problems on a big box doing something
> > like say mysql queries of a local database, blasting retrieved data out
> > over industrial strength copper/glass or such.  My desktop box surely
> > won't notice, but it seems heavy lifters might.  I saw the reason for
> > it, but I was left wondering why we used to care about it, but no more,
> > so here I am to see if I can get my curiosity spot scratched.
> > 
> > I'll sorta miss good ole tbench in scheduler litmus test role.  On the
> > bright side, localhost based scalability reports are history.  Oh wait.
> 
> Sure, this patch re-introduces the dst->__refcnt false sharing for
> loopback.
> 
> Hopefully, with current kernels it's not an issue, because each cpu gets
> a different dst.

But but.. I'm mildly concerned over stable kernel performance where a
serious looking regression appeared out of the blue, not a new kernel
where each cpu getting a percpu dst will hopefully mitigate any of the
potential performance issues.. I may well be imagining.

> (It would be an issue if the connect() calls are all done on a single
> cpu, than traffic handled on other cpus)

(that didn't sink right in, but I may generally get it "very unlikely")

> So please try tbench on linux-3.8 or current git tree ;)

Will do.  Thanks, and glad to see that often annoying but quite useful
indicator isn't dead.

-Mike
