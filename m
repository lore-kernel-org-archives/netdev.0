From: Christopher Chan <cchan@outblaze.com>
Subject: linux 2.6.9 still having network code problems
Date: Tue, 02 Nov 2004 16:14:35 +0800
Message-ID: <418741EB.3080701@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mr. Morton,

I'm ccing you due to the oom-killer stuff.


Previously with 2.6.7 I had to use this values in sysctl to be able to 
continue to access the box:

net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.route.gc_thresh = 65536
net.ipv4.route.max_size = 1048576

2.6.9 without this values gave me similar problems with 2.6.7 without 
the above values.

Sample log lines below:

There are multiple oom-killer lines (different pid for smtpd process) 
and the network related messages repeated until the box was rebooted 
about 45 mins later.

Nov  1 03:15:58 spf5-3 kernel: oom-killer: gfp_mask=0x1d2
Nov  1 03:15:58 spf5-3 kernel: DMA per-cpu:
Nov  1 03:15:58 spf5-3 kernel: cpu 0 hot: low 2, high 6, batch 1
Nov  1 03:15:58 spf5-3 kernel: cpu 0 cold: low 0, high 2, batch 1
Nov  1 03:15:58 spf5-3 kernel: cpu 1 hot: low 2, high 6, batch 1
Nov  1 03:15:58 spf5-3 kernel: cpu 1 cold: low 0, high 2, batch 1
Nov  1 03:15:58 spf5-3 kernel: Normal per-cpu:
Nov  1 03:15:58 spf5-3 kernel: cpu 0 hot: low 32, high 96, batch 16
Nov  1 03:15:58 spf5-3 kernel: cpu 0 cold: low 0, high 32, batch 16
Nov  1 03:15:58 spf5-3 kernel: cpu 1 hot: low 32, high 96, batch 16
Nov  1 03:15:58 spf5-3 kernel: cpu 1 cold: low 0, high 32, batch 16
Nov  1 03:15:58 spf5-3 kernel: HighMem per-cpu:
Nov  1 03:15:58 spf5-3 kernel: cpu 0 hot: low 16, high 48, batch 8
Nov  1 03:15:58 spf5-3 kernel: cpu 0 cold: low 0, high 16, batch 8
Nov  1 03:15:58 spf5-3 kernel: cpu 1 hot: low 16, high 48, batch 8
Nov  1 03:15:58 spf5-3 kernel: cpu 1 cold: low 0, high 16, batch 8
Nov  1 03:15:58 spf5-3 kernel:
Nov  1 03:15:58 spf5-3 kernel: Free pages:        1264kB (128kB HighMem)
Nov  1 03:15:58 spf5-3 kernel: Active:204122 inactive:68 dirty:0 
writeback:0 unstable:0 free:316 slab:27673 mapped:204956 pagetables:22623
Nov  1 03:15:58 spf5-3 kernel: DMA free:16kB min:16kB low:32kB high:48kB 
active:10544kB inactive:0kB present:16384kB
Nov  1 03:15:59 spf5-3 kernel: protections[]: 0 0 0
Nov  1 03:15:59 spf5-3 kernel: Normal free:1120kB min:936kB low:1872kB 
high:2808kB active:693760kB inactive:556kB present:901120kB
Nov  1 03:15:59 spf5-3 kernel: protections[]: 0 0 0
Nov  1 03:15:59 spf5-3 kernel: HighMem free:128kB min:128kB low:256kB 
high:384kB active:112132kB inactive:152kB present:131072kB
Nov  1 03:15:59 spf5-3 kernel: protections[]: 0 0 0
Nov  1 03:15:59 spf5-3 kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 0*64kB 
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16kB
Nov  1 03:15:59 spf5-3 kernel: Normal: 104*4kB 4*8kB 0*16kB 1*32kB 
0*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1248kB
Nov  1 03:15:59 spf5-3 kernel: HighMem: 0*4kB 0*8kB 0*16kB 2*32kB 1*64kB 
0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 128kB
Nov  1 03:15:59 spf5-3 kernel: Swap cache: add 0, delete 0, find 0/0, 
race 0+0
Nov  1 03:16:00 spf5-3 kernel: Out of Memory: Killed process 21861 (smtpd).
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
failed at net/ipv4/tcp.c (1284)
Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
failed at net/ipv4/tcp.c (1284)
Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
net/ipv4/tcp.c (1348)
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
failed at net/ipv4/tcp.c (1284)
Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
net/ipv4/tcp.c (1348)
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
failed at net/ipv4/tcp.c (1284)
Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
net/ipv4/tcp.c (1348)
