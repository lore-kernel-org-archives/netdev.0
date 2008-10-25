From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 00:24:20 -0700 (PDT)
Message-ID: <20081025.002420.82739316.davem@davemloft.net>
References: <20081024.221653.23695396.davem@davemloft.net>
	<1224914333.3822.18.camel@marge.simson.net>
	<1224917623.4929.15.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: efault@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751095AbYJYHYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 03:24:42 -0400
In-Reply-To: <1224917623.4929.15.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Galbraith <efault@gmx.de>
Date: Sat, 25 Oct 2008 08:53:43 +0200

> On Sat, 2008-10-25 at 07:58 +0200, Mike Galbraith wrote:
> 2.6.24.7-up
> ring-test   - 1.100 us/cycle  = 909 KHz  (gcc-4.1)
> ring-test   - 1.068 us/cycle  = 936 KHz  (gcc-4.3)
> netperf     - 122300.66 rr/s  = 244 KHz  sb 280 KHz / 140039.03 rr/s
> tbench      - 341.523 MB/sec
> 
> 2.6.25.17-up
> ring-test   - 1.163 us/cycle  = 859 KHz  (gcc-4.1)
> ring-test   - 1.129 us/cycle  = 885 KHz  (gcc-4.3)
> netperf     - 132102.70 rr/s  = 264 KHz  sb 275 KHz / 137627.30 rr/s
> tbench      - 361.71 MB/sec
> 
> ..in 25, something happened that dropped my max context switch rate from
> ~930 KHz to ~885 KHz.  Maybe I'll have better luck trying to find that.
> Added to to-do list.  Benchmark mysteries I'm going to have to leave
> alone, they've kicked my little butt quite thoroughly ;-)

But note that tbench performance improved a bit in 2.6.25.

In my tests I noticed a similar effect, but from 2.6.23 to 2.6.24,
weird.

Just for the public record here are the numbers I got in my testing.
Each entry was run purely on the latest 2.6.X-stable tree for each
release.  First is the tbench score and then there are 40 numbers
which are sparc64 cpu cycle counts of default_wake_function().

v2.6.22:

	Throughput 173.677 MB/sec  2 clients  2 procs  max_latency=38.192 ms

	1636 1483 1552 1560 1534 1522 1472 1530 1518 1468
	1534 1402 1468 1656 1383 1362 1516 1336 1392 1472
	1652 1522 1486 1363 1430 1334 1382 1398 1448 1439
	1662 1540 1526 1472 1539 1434 1452 1492 1502 1432

v2.6.23: This is when CFS got added to the tree.

	Throughput 167.933 MB/sec  2 clients  2 procs  max_latency=25.428 ms

	3435 3363 3165 3304 3401 3189 3280 3243 3156 3295
	3439 3375 2950 2945 2727 3383 3560 3417 3221 3271
	3595 3293 3323 3283 3267 3279 3343 3293 3203 3341
	3413 3268 3107 3361 3245 3195 3079 3184 3405 3191

v2.6.24:

	Throughput 170.314 MB/sec  2 clients  2 procs  max_latency=22.121 ms

	2136 1886 2030 1929 2021 1941 2009 2067 1895 2019
	2072 1985 1992 1986 2031 2085 2014 2103 1825 1705
	2018 2034 1921 2079 1901 1989 1976 2035 2053 1971
	2144 2059 2025 2024 2029 1932 1980 1947 1956 2008

v2.6.25:

	Throughput 165.294 MB/sec  2 clients  2 procs  max_latency=108.869 ms

	2551 2707 2674 2771 2641 2727 2647 2865 2800 2796
	2793 2745 2609 2753 2674 2618 2671 2668 2641 2744
	2727 2616 2897 2720 2682 2737 2551 2677 2687 2603
	2725 2717 2510 2682 2658 2581 2713 2608 2619 2586

v2.6.26:

	Throughput 160.759 MB/sec  2 clients  2 procs  max_latency=31.420 ms

	2576 2492 2556 2517 2496 2473 2620 2464 2535 2494
	2800 2297 2183 2634 2546 2579 2488 2455 2632 2540
	2566 2540 2536 2496 2432 2453 2462 2568 2406 2522
	2565 2620 2532 2416 2434 2452 2524 2440 2424 2412

v2.6.27:

	Throughput 143.776 MB/sec  2 clients  2 procs  max_latency=31.279 ms

	4783 4710 27307 4955 5363 4270 4514 4469 3949 4422
	4177 4424 4510 18290 4380 3956 4293 4368 3919 4283
	4607 3960 4294 3842 18957 3942 4402 4488 3988 5157
	4604 4219 4186 22628 4289 4149 4089 4543 4217 4075
