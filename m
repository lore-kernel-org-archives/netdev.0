From: Christopher Chan <cchan@outblaze.com>
Subject: Re: linux 2.6.9 still having network code problems
Date: Thu, 04 Nov 2004 09:08:28 +0800
Message-ID: <4189810C.4080302@outblaze.com>
References: <418741EB.3080701@outblaze.com> <20041102011918.2b453e21.akpm@osdl.org> <4187478A.1040002@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christopher Chan <cchan@outblaze.com>, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <4187478A.1040002@outblaze.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christopher Chan wrote:
> 
>>> Previously with 2.6.7 I had to use this values in sysctl to be able 
>>> to continue to access the box:
>>>
>>> net.ipv4.tcp_max_syn_backlog = 2048
>>> net.ipv4.route.gc_thresh = 65536
>>> net.ipv4.route.max_size = 1048576

>>> Nov  1 03:16:00 spf5-3 kernel: Out of Memory: Killed process 21861 
>>> (smtpd).
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>> failed at net/ipv4/tcp.c (1284)
>>> Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>> failed at net/ipv4/tcp.c (1284)
>>> Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>> tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>> net/ipv4/tcp.c (1348)
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>> failed at net/ipv4/tcp.c (1284)
>>> Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>> tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>> net/ipv4/tcp.c (1348)
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>> failed at net/ipv4/tcp.c (1284)
>>> Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>> Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>> tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>> net/ipv4/tcp.c (1348)
>>
>>
>>
>> This is a networking bug.
>>
> 
> Yes...it's the same one that won't allow me to use the e100 driver with 
> NAPI enabled with or without them sysctl tweaks and the same one that 
> forces me to use the tweaks without NAPI enabled for the e100 driver.
> 
> With NAPI enabled, I see the problem when under pressure.
> 
> FYI, the 2.6.9 kernel is running with NAPI enabled.
> 

2.6.9 kernel with NAPI enabled and sysctl tweaks listed at the top of 
mail still triggers network code problems:

Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:46:45 spf0 kernel: KERNEL: assertion (tp->copied_seq == 
tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed a
t net/ipv4/tcp.c (1348)
Nov  3 10:47:56 spf0 kernel: kb)->end_seq)) failed at net/ipv4/tcp.c (1061)
Nov  3 10:47:56 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:47:56 spf0 kernel: KERNEL: assertion (!skb || 
before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq)) failed at net/ipv
4/tcp.c (1061)
......................................
Nov  3 10:47:59 spf0 kernel: printk: 156 messages suppressed.
Nov  3 10:47:59 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:47:59 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:47:59 spf0 kernel: KERNEL: assertion (!skb || 
before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq)) failed at net/ipv
4/tcp.c (1061)
Nov  3 10:47:59 spf0 kernel: printk: 106 messages suppressed.
Nov  3 10:47:59 spf0 kernel: printk: 121 messages suppressed.
Nov  3 10:47:59 spf0 kernel: printk: 222 messages suppressed.
Nov  3 10:47:59 spf0 kernel: printk: 151 messages suppressed.
Nov  3 10:47:59 spf0 kernel: KERNEL: assertion (flags & MSG_PEEK) failed 
at net/ipv4/tcp.c (1284)
Nov  3 10:47:59 spf0 kernel: recvmsg bug: copied D51512C9 seq D51512FA
Nov  3 10:47:59 spf0 kernel: printk: 163 messages suppressed.
Nov  3 10:48:04 spf0 kernel: printk: 216 messages suppressed.

apparent recovery...

Nov  3 11:15:44 spf0 kernel: printk: 15 messages suppressed.
Nov  3 11:23:42 spf0 kernel: printk: 61 messages suppressed.

Box is gone...

Please continue to keep available the NAPI disable/enable option in the 
e100 driver.
