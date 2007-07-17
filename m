From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Linux 2.6.22: had to reboot after OOM
Date: Tue, 17 Jul 2007 02:57:11 -0700
Message-ID: <20070717025711.1f36e70f.akpm@linux-foundation.org>
References: <20070715120321.kyvbw5wjx6mwviu6@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42825 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757642AbXGQJ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 05:57:38 -0400
In-Reply-To: <20070715120321.kyvbw5wjx6mwviu6@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Jul 2007 15:03:21 +0300 Sami Farin <safari-kernel@safari.iki.fi> wrote:

> After I got this error [1], system got real slow, like 386 having 32 MB of RAM
> and swapping constantly.
> My system is P4 SMP with 1GB of RAM.
> 
> I got this same behavior with 2.6.19, too, but then I used GNU cp v6.9
> which had micro-optimization which did not bother doing read() for regular
> files, like /proc/vmstat , instead, it generated 0-byte destination file
> (I noticed that only after rebooting).
> So I do not have useful debug info for 2.6.19.
> 
> And now my version of cp does not have that micro-optimization.
> 
> I also attached vmstat and slabinfo , in case somebody can figure out
> something out of them.
> I also now use --probes=5 for ipset nethash... uses less mem but is slower.

I don't know why your system went bad like that.

> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa st
>  0  2 762376 748392      0  17104   11    8    52    65   64    53 10  3 85  3  0
>  0  3 762376 748664      0  17144  456   12   908    24  237  3044  2  3 26 70  0
>  0  2 762376 749544      0  16492  464  284  1440   288  248  3633  2  5 14 79  0
>  0  3 762376 749916      0  16392  432    0  1368    16  239  3360  1  2  5 93  0
>  0  3 762376 751108      0  15740  512  432  1656   460  214  3751  1  3 28 69  0
>  0  7 762376 751740      0  15512  532  104  1920   131  237  4014  2  4  5 90  0
>  0 10 762436 755064      0  15652  200 3172   992  3264  274  5086  1  3  1 96  0
>  0 11 762504 757208      0  15156  144  836   624   926  204  2602  1  2  0 98  0
>  0 13 762680 766384      0  12740   36 7284    96  7308  252  8643  0  5  0 95  0
>  0 14 762772 771312      0  11696   12 3908   132  3912  253  5153  0  3  0 97  0
>  0 13 763044 778536      0  10356  184 8088   572  8088  249  6889  1  3  0 97  0
>  0 15 763092 781380      0  10284    0 2136   532  2160  176  2387  1  2  0 98  0
>  0 16 763360 785428      0  10008   60 4884  1312  4985  281  4798  0  5  0 96  0
>  0 19 763636 791192      0   8548   24 6264   476  6268  219  6732  0  3  0 97  0
>  0 18 763824 799184      0   6240    0 7500    52  7504  217  7080  1  6  0 94  0
>  0 18 763872 802196      0   5816    0 2628   552  2640  194  3851  0  4  0 96  0
>  0 28 764048 805072      0   5168   92 1760  1180  1772  185  2703  0  5  0 94  0
>  0 30 764048 806032      0   5256   36  164   364   234  126  1448  0  1  0 99  0
>  0 31 764048 807728      0   4732   32   40    92    84  152  1824  0  3  0 97  0
>  0 35 764056 809372      0   4332 1100  532  9084   804  194  1986  0  7  0 94  0
>  0 74 764012 839544      0   8100 1604    0  5660    12 4216 46853  0  8  0 92  0
> 
> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
>  r  b   swpd   free  inact active   si   so    bi    bo   in    cs us sy id wa st
>  0 14 762504 757108   4004  90724   11    8    52    65   64    53 10  3 85  3  0
>  0 13 762676 764608   8768  78084   44 6324   288  6370  251  7697  0  4  0 95  0
>  0 14 762772 770832  12404  68328   12 4868   128  4880  243  6161  0  4  0 96  0
>  0 13 763044 778536  24248  48736  180 7908   548  7912  296  7208  0  3  0 97  0
>  0 16 763092 781380  21196  49004    4 2312   560  2336  185  2524  1  1  0 98  0
>  0 16 763360 784584  40040  27048   60 4088  1312  4189  267  3964  0  4  0 96  0
>  0 19 763636 791192  36552  23804   24 7064   392  7068  227  7600  0  4  0 96  0
>  0 18 763824 798896  36928  15568    0 7352   136  7356  219  6902  0  5  0 94  0
>  0 19 763872 802088  41372   7876    0 2776   548  2788  195  3917  0  4  0 96  0
>  0 25 764048 804636  39896   6932   56 1760   920  1772  170  2602  0  4  0 95  0
>  0 30 764048 806032  39308   6272   72  164   628   234  131  1579  0  2  0 98  0
>  0 30 764048 807500  38316   5768   32   40    84    68  149  1630  0  2  0 98  0
>  1 34 764056 808476  37900   5444   20  192   660   242  184  1883  0  6  0 94  0
>  1 37 764056 811148  38772   1740   20  100   388   104  168  2409  0  5  0 95  0
>  0 38 764056 813056  34164   4536    0    0   124    47  227  2590  0  6  0 94  0
>  0 38 764056 815500  32924   3308   40    0   608     5  228  2448  0  4  0 96  0
> 10 37 764056 817764  30404   3800    0   16   260    20  323  3795  0 10  0 90  0
>  1 37 764056 819548  28552   3744    0   20   148    56  207  2275  0  6  0 94  0
>  1 38 764056 820828  27004   4028   20    8   496    21  216  1703  0  3  0 97  0
>  0 71 764056 820064  28228   3508  600    0  1424     4  140   826  0  2  0 99  0
>  0 73 764028 822568  25928   3404   68   36   332    48  205  2223  0  5  0 95  0
> 
> 
> 
> As a comparison, these are stats after booting, with similar workload:
> 
> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa st
>  2  0 290544  12728      0 444216    2   13   213   285  144   922  7  2 82  9  0
>  0  0 290544  12672      0 444264    0    0    16  1616  270  1881  2  2 96  0  0
>  0  0 290544  12752      0 444280    0    0    16    56  245  1687  2  2 96  1  0
>  0  0 290544  12876      0 444280    0    0     0    31  243  1604  2  1 97  0  0
>  0  0 290544  12520      0 444260   48    0    80    50  333  1708  2  2 94  2  0
>  0  0 290544  12656      0 444424    0    0   136   114  269  1817  3  2 95  1  0
>  0  0 290544  12672      0 444448    0    0    12  1687  330  1822  2  2 97  0  0
> 
> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
>  r  b   swpd   free  inact active   si   so    bi    bo   in    cs us sy id wa st
>  2  0 290544  18756 316324 420928    2   13   212   284  144   922  7  2 82  9  0
>  0  0 290544  18716 316360 421112    0    0    32    72  273  1979  2  2 96  0  0
>  0  0 290544  18472 316504 421152    0    0   144    51  256  1644  3  1 97  0  0
>  0  0 290544  18256 316520 421144    0    0    16    63  240  1768  2  3 96  1  0
>  0  0 290544  18264 316520 421160    0    0     0   121  243  1770  2  1 97  0  0
>  0  0 290544  18312 316520 421168    0    0     8    51  235  1789  2  1 97  0  0
>  0  0 290544  18252 316544 421168    0    0    24   204  296  2017  2  1 96  1  0
> 
> ...
> 
> and the rest are after the mem allocation failure.
> 
> 2007-07-15 10:43:02.271042500 <6>[246964.992391] SysRq : Show Memory
> 2007-07-15 10:43:02.271082500 <6>[246964.992399] Mem-info:
> 2007-07-15 10:43:02.271103500 <4>[246964.992401] DMA per-cpu:
> 2007-07-15 10:43:02.271123500 <4>[246964.992405] CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> 2007-07-15 10:43:02.271144500 <4>[246964.992409] CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> 2007-07-15 10:43:02.271164500 <4>[246964.992412] Normal per-cpu:
> 2007-07-15 10:43:02.271185500 <4>[246964.992415] CPU    0: Hot: hi:  186, btch:  31 usd:  31   Cold: hi:   62, btch:  15 usd:  50
> 2007-07-15 10:43:02.271205500 <4>[246964.992419] CPU    1: Hot: hi:  186, btch:  31 usd:  21   Cold: hi:   62, btch:  15 usd:  59
> 2007-07-15 10:43:02.271225500 <4>[246964.992422] HighMem per-cpu:
> 2007-07-15 10:43:02.271245500 <4>[246964.992425] CPU    0: Hot: hi:   42, btch:   7 usd:   6   Cold: hi:   14, btch:   3 usd:   1
> 2007-07-15 10:43:02.271266500 <4>[246964.992429] CPU    1: Hot: hi:   42, btch:   7 usd:   4   Cold: hi:   14, btch:   3 usd:   1
> 2007-07-15 10:43:02.271287500 <4>[246964.992434] Active:23152 inactive:648 dirty:8 writeback:50 unstable:0
> 2007-07-15 10:43:02.271307500 <4>[246964.992436]  free:189843 slab:8987 mapped:3892 pagetables:1960 bounce:0
> 2007-07-15 10:43:02.271329500 <4>[246964.992440] DMA free:10384kB min:68kB low:84kB high:100kB active:0kB inactive:0kB present:16256kB pages_scanned:0 all_unreclaimable? yes
> 2007-07-15 10:43:02.271349500 <4>[246964.992444] lowmem_reserve[]: 0 873 975
> 2007-07-15 10:43:02.271371500 <4>[246964.992451] Normal free:742488kB min:3744kB low:4680kB high:5616kB active:2860kB inactive:212kB present:894080kB pages_scanned:0 all_unreclaimable? no

You have heaps of free ZONE_NORMAL memory.

> 
> -------------------------------------------------------------------------------------
> 
> [1]
> 
> 2007-07-15 10:12:40.640668500 <4>[245143.816358] net/ipv4/netfilter/ip_set_nethash.c: retry: rehashing of set blockedp2pnew triggered: hashsize grows from 262144 to 348651
> 2007-07-15 10:12:40.640672500 <4>[245143.816379] ipset: page allocation failure. order:9, mode:0x20

ipset does an order-9 atomic allocation?  That's optimistic.  Hopefully it's
just doing a probe-for-the-largest-allocation operation, albeit rather stupidly.

ipset is some out-of-tree patch you added, I assume?

> 2007-07-15 10:12:40.640808500 <4>[245143.816548] Normal free:9772kB min:3744kB low:4680kB high:5616kB active:465640kB inactive:228696kB present:894080kB pages_scanned:32 all_unreclaimable? no

No free memory, but lots of presumably-reclaimable pagecache there.
