From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: user namespaces v3: continue targetting capabilities
Date: Tue, 13 Sep 2011 14:43:47 +0000
Message-ID: <20110913144347.GA23008@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 50-56-35-84.static.cloud-ips.com ([50.56.35.84]:34952 "EHLO
	mail" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754403Ab1IMOmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 10:42:36 -0400
Content-Disposition: inline
In-Reply-To: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did a bit of basic performance testing - just running unixbench
and doing a kernel compile (without profiling) with and without
this patchset, with USER_NS enabled for both.  I could find no
meaningful impact.

473.01user 32.48system 9:05.44elapsed 92%CPU (0avgtext+0avgdata 430752maxresident)k
112736inputs+576936outputs (8major+22057422minor)pagefaults 0swaps
473.78user 33.12system 9:06.14elapsed 92%CPU (0avgtext+0avgdata 430752maxresident)k
116656inputs+576936outputs (12major+22056621minor)pagefaults 0swaps

and with:
474.09user 31.62system 9:05.70elapsed 92%CPU (0avgtext+0avgdata 430752maxresident)k
112648inputs+576936outputs (7major+22056909minor)pagefaults 0swaps
472.54user 33.26system 9:05.43elapsed 92%CPU (0avgtext+0avgdata 430608maxresident)k
116656inputs+576936outputs (12major+22058358minor)pagefaults 0swaps

I'll append the full unixbench outputs below, but index score without
the patchset was 1594.3, and with the patchset was 1597.4.

thanks,
-serge

=====================================================================
unixbench without patchset:
=====================================================================
   BYTE UNIX Benchmarks (Version 5.1.3)

   System: marula: GNU/Linux
   OS: GNU/Linux -- 3.0.0-11-server -- #17-Ubuntu SMP Fri Sep 9 19:31:36 UTC 2011
   Machine: x86_64 (x86_64)
   Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")
   CPU 0: Intel(R) Xeon(R) CPU E5530 @ 2.40GHz (4800.3 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext, SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   02:43:44 up  3:00,  1 user,  load average: 0.05, 0.03, 0.03; runlevel 2

------------------------------------------------------------------------
Benchmark Run: Mon Sep 12 2011 02:43:44 - 03:11:55
1 CPU in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       28147322.1 lps   (10.0 s, 7 samples)
Double-Precision Whetstone                     3289.7 MWIPS (10.0 s, 7 samples)
Execl Throughput                               4557.5 lps   (30.0 s, 2 samples)
File Copy 1024 bufsize 2000 maxblocks       1145450.6 KBps  (30.0 s, 2 samples)
File Copy 256 bufsize 500 maxblocks          312941.7 KBps  (30.0 s, 2 samples)
File Copy 4096 bufsize 8000 maxblocks       1969030.8 KBps  (30.0 s, 2 samples)
Pipe Throughput                             2080076.5 lps   (10.0 s, 7 samples)
Pipe-based Context Switching                 331910.6 lps   (10.0 s, 7 samples)
Process Creation                              14921.7 lps   (30.0 s, 2 samples)
Shell Scripts (1 concurrent)                   6989.7 lpm   (60.0 s, 2 samples)
Shell Scripts (8 concurrent)                    913.9 lpm   (60.0 s, 2 samples)
System Call Overhead                        3453367.4 lps   (10.0 s, 7 samples)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   28147322.1   2411.9
Double-Precision Whetstone                       55.0       3289.7    598.1
Execl Throughput                                 43.0       4557.5   1059.9
File Copy 1024 bufsize 2000 maxblocks          3960.0    1145450.6   2892.6
File Copy 256 bufsize 500 maxblocks            1655.0     312941.7   1890.9
File Copy 4096 bufsize 8000 maxblocks          5800.0    1969030.8   3394.9
Pipe Throughput                               12440.0    2080076.5   1672.1
Pipe-based Context Switching                   4000.0     331910.6    829.8
Process Creation                                126.0      14921.7   1184.3
Shell Scripts (1 concurrent)                     42.4       6989.7   1648.5
Shell Scripts (8 concurrent)                      6.0        913.9   1523.2
System Call Overhead                          15000.0    3453367.4   2302.2
                                                                   ========
System Benchmarks Index Score                                        1594.3

=====================================================================
unixbench with patchset:
=====================================================================
   BYTE UNIX Benchmarks (Version 5.1.3)

   System: marula: GNU/Linux
   OS: GNU/Linux -- 3.0.0-11-server -- #17userns1 SMP Mon Sep 12 13:42:40 UTC 2011
   Machine: x86_64 (x86_64)
   Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")
   CPU 0: Intel(R) Xeon(R) CPU E5530 @ 2.40GHz (4799.6 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext, SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   12:42:07 up 8 min,  1 user,  load average: 0.00, 0.01, 0.02; runlevel 2

------------------------------------------------------------------------
Benchmark Run: Mon Sep 12 2011 12:42:07 - 13:10:19
1 CPU in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       28232156.4 lps   (10.0 s, 7 samples)
Double-Precision Whetstone                     3290.0 MWIPS (10.0 s, 7 samples)
Execl Throughput                               4553.7 lps   (29.9 s, 2 samples)
File Copy 1024 bufsize 2000 maxblocks       1142317.5 KBps  (30.0 s, 2 samples)
File Copy 256 bufsize 500 maxblocks          317068.8 KBps  (30.0 s, 2 samples)
File Copy 4096 bufsize 8000 maxblocks       1956611.4 KBps  (30.0 s, 2 samples)
Pipe Throughput                             2086728.8 lps   (10.0 s, 7 samples)
Pipe-based Context Switching                 343275.1 lps   (10.0 s, 7 samples)
Process Creation                              14718.6 lps   (30.0 s, 2 samples)
Shell Scripts (1 concurrent)                   6989.0 lpm   (60.0 s, 2 samples)
Shell Scripts (8 concurrent)                    913.6 lpm   (60.0 s, 2 samples)
System Call Overhead                        3434956.0 lps   (10.0 s, 7 samples)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   28232156.4   2419.2
Double-Precision Whetstone                       55.0       3290.0    598.2
Execl Throughput                                 43.0       4553.7   1059.0
File Copy 1024 bufsize 2000 maxblocks          3960.0    1142317.5   2884.6
File Copy 256 bufsize 500 maxblocks            1655.0     317068.8   1915.8
File Copy 4096 bufsize 8000 maxblocks          5800.0    1956611.4   3373.5
Pipe Throughput                               12440.0    2086728.8   1677.4
Pipe-based Context Switching                   4000.0     343275.1    858.2
Process Creation                                126.0      14718.6   1168.1
Shell Scripts (1 concurrent)                     42.4       6989.0   1648.3
Shell Scripts (8 concurrent)                      6.0        913.6   1522.6
System Call Overhead                          15000.0    3434956.0   2290.0
                                                                   ========
System Benchmarks Index Score                                        1597.4
