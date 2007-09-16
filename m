From: "David Madsen" <david.madsen@gmail.com>
Subject: Re: r8169: slow samba performance
Date: Sat, 15 Sep 2007 18:11:13 -0700
Message-ID: <ec7e30370709151811i5db4d0d2kadacf3250afacaef@mail.gmail.com>
References: <ec7e30370709090044m55efbbcl3cb9e9489f2d5e6e@mail.gmail.com>
	 <20070909153312.GA29586@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:44474 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbXIPBLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 21:11:18 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1155454fkz
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2007 18:11:16 -0700 (PDT)
In-Reply-To: <20070909153312.GA29586@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you see a difference in the system load too, say a few lines of 'vmstat 1' ?

This is running on a dual core machine which explains the 50/50
sys/idle in vmstat.

with 8168 hack  (patch #0002):

writes:
isis tmp # dd if=/dev/zero of=test.fil bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.5288 s, 77.5 MB/s

 procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0    200 714568   2944 227964    0    0     4 74592 44243 12190  1 45 52  2
 1  0    200 637656   3028 305016    0    0     0 79324 45579 12795  1 48 27 24
 1  0    200 556688   3112 383816    0    0     4 82880 48222 13901  1 49 50  1
 1  0    200 475936   3196 462280    0    0     8 78736 47925 13942  1 50 49  1
 0  0    200 394992   3284 540676    0    0    12 74592 47657 13949  1 48 50  1

reads:
isis tmp # dd if=test.fil of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 34.7543 s, 30.2 MB/s

 procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0    200  18652   3952 913524    0    0 19996     0 18650 2000  1 13 83  4
 0  0    200  19476   3940 912772    0    0 24576     0 15846 1725  0 12 88  0
 0  0    200  22540   3940 910156    0    0 14336     0 9470 1024  0  8 91  0
 0  0    200  25180   3924 907660    0    0 14336     0 10084 1076  0  8 92  0
 1  0    200  17764   3920 915248    0    0 24576     0 16046 1669  1 13 87  0
 0  0    200  18732   3936 914528    0    0 24592     0 17136 1963  0 13 86  1
 0  0    200  29152   3924 904816    0    0 40996     0 25609 2776  0 19 80  1
 0  0    200  35040   3880 899548    0    0 36872     0 24288 2589  1 18 81  1
 0  0    200  15524   3904 919540    0    0 36888     0 24506 2664  0 19 80  0
 0  0    200  23964   3904 911872    0    0 43048    64 27498 2934  0 22 76  2
 0  0    200  15960   3908 920564    0    0 59444     0 38224 4096  0 29 68  3
 0  0    200  14936   3908 921916    0    0 26652     0 18401 1957  1 15 82  3
 1  0    200  30392   3916 906864    0    0 10248     0 7225  863  0  6 94  1
 0  0    200  14836   3896 922768    0    0 32796     0 20830 2313  1 16 80  4
 0  0    200  35152   3896 902788    0    0 30748     0 20679 2340  0 16 79  5

with ndelay(10) loop:

writes:
isis tmp # dd if=/dev/zero of=test.fil bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.7967 s, 76.0 MB/s

 1  0      0 694080   6448 248252    0    0     0 78736 44235 12588  1 50 50  0
 1  0      0 613448   6524 326400    0    0     0 78736 44215 12477  1 50 50  0
 1  0      0 535612   6628 403796    0    0     8 91668 45789 10741  0 52 23 24
 0  0      0 454132   6704 482848    0    0     0 78736 47082 10795  1 51 49  0
 1  0      0 373804   6784 560780    0    0     4 75008 46826 10418  1 49 51  0
 1  0      0 292216   6860 639976    0    0     0 82880 47279 10544  1 51 49  0

reads:
isis tmp # dd if=test.fil of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 21.894 s, 47.9 MB/s

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0      0  14968   3736 920920    0    0 44968     0 21886 3068  0 33 60  7
 0  0      0  13120   3672 922908    0    0 32768     0 17486 2326  0 26 74  0
 1  0      0  24796   3640 912136    0    0 51212     4 29417 3637  1 44 56  0
 1  0      0  52104   3600 886072    0    0 49688     0 29329 3602  0 42 57  0
 1  0      0  44548   3564 894164    0    0 43808     0 28066 3418  0 41 57  2
 0  0      0  16676   3608 922400    0    0 47148     0 25292 3313  0 36 59  4
 0  0      0  37392   3604 902580    0    0 51248     0 27554 3512  1 40 59  1
 1  0      0  23988   3648 916468    0    0 49196     0 26621 3393  0 39 61  1
 1  0      0  16232   3696 924692    0    0 51248     0 28792 3536  1 43 56  1
 0  1      0  18548   3732 921472    0    0 39416     0 21470 2736  1 31 66  2
 2  0      0  13620   3760 928296    0    0 40520     0 22081 2818  0 33 65  1
 0  0      0  18828   3732 923900    0    0 53252     0 28577 3611  0 43 57  0
 1  0    160  13308   3736 929712    0    0 43012     0 22924 2920  1 33 66  0
 1  0    176  13316   2668 931348    0    0 40964     0 23122 2899  0 34 66  0
 0  0    176  13764   1900 932416    0    0 53260     0 28571 3601  0 42 57  0
 0  1    176  14076   1744 931300    0    0 51672     0 28600 3845  1 42 58  0
 1  0    176  16380   1620 931164    0    0 52828     0 27832 3518  1 41 58  1

Load is definately higher with the ndelay(10) loop but throughput on
reads is quite a bit better as well.

> Can you add the patch below on top of #0002 and see if there is some
> benefit from it ?

writes:
isis tmp # dd if=/dev/zero of=test.fil bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.6414 s, 76.9 MB/s

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  1    200 496436   5676 440184    0    0   342 16003 8770 2051  4 26 55 14
 2  0    200 431808   5692 504456    0    0     4 67180 36908 11169  1 43 26 31
 1  0    200 351524   5692 582756    0    0     0 76508 45336 11191  1 49 50  0
 2  0    200 270928   5768 661040    0    0     0 78736 46283 11709  1 50 50  0
 1  0    200 190804   5844 738648    0    0     0 78736 45110 10442  0 49 51  0

reads:
isis tmp # dd if=test.fil of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 31.3864 s, 33.4 MB/s

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0    200  14612   2604 929304    0    0 24576     0 16047 1715  1 15 85  0
 0  0    200  16752   2604 927504    0    0 36864     4 24174 2618  1 23 77  0
 0  0    200  14308   2592 930324    0    0 45060  1272 28799 3281  0 27 69  4
 1  0    200  13800   2592 930896    0    0 34816     0 22206 2596  1 20 77  3
 0  0    200  13940   2592 930736    0    0 12288     0 7745  943  0  8 92  0
 1  0    200  17096   2580 927552    0    0 12288     0 7963  957  0  7 93  0


>
> I'd welcome if you could try the patch below on top of #0002 too:
>

writes:

after finishing writes: eth0: wait_max = 9

isis tmp # dd if=/dev/zero of=test.fil bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 13.8243 s, 75.9 MB/s

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0      0 180056   3000 752876    0    0     0 74592 37500 4810  1 52 47  0
 2  0      0 103060   3072 827492    0    0     0 77780 36297 3803  1 49 50  0
 1  0      0  32320   3152 901552    0    0     0 75964 38510 5022  1 54 40  5
 1  0      0  40728   3024 891948    0    0     0 74592 35930 3861  1 51 49  0
 1  0      0  18328   3092 913288    0    0     0 74592 36354 4391  1 53 47  0

reads:

isis tmp # dd if=test.fil of=/dev/null bs=1M count=1000
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 23.5534 s, 44.5 MB/s

 0  0    200  15696   2884 921820    0    0 40960     0 26874 2792  0 38 62  0
 1  0    200  21572   2876 915680    0    0 44728    60 30070 3142  1 43 56  0
 1  0    200 143944   2876 796260    0    0 43336     0 29704 3064  1 44 51  6
 1  0    200  99132   2876 841268    0    0 45056     0 30130 3062  0 42 58  0
 1  0    200  62292   2876 877832    0    0 36864     0 23757 2468  1 34 66  0
 1  0    200  19332   2876 921140    0    0 43008     0 29924 3073  0 42 57  0

I've never seen wait_max go higher than 9 as of yet.

Let me know if I can provide any more useful information.

--David Madsen
