From: Christopher Chan <cchan@outblaze.com>
Subject: Re: linux 2.6.9 still having network code problems
Date: Tue, 02 Nov 2004 16:38:34 +0800
Message-ID: <4187478A.1040002@outblaze.com>
References: <418741EB.3080701@outblaze.com> <20041102011918.2b453e21.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041102011918.2b453e21.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>>Previously with 2.6.7 I had to use this values in sysctl to be able to 
>>continue to access the box:
>>
>>net.ipv4.tcp_max_syn_backlog = 2048
>>net.ipv4.route.gc_thresh = 65536
>>net.ipv4.route.max_size = 1048576
> 
> 
> Why?

without these, i get dst cache overflow errors and the similar 
networking error messages and the box is inaccessible via the network 
and unusable via serial console.
> 
> 
>>2.6.9 without this values gave me similar problems with 2.6.7 without 
>>the above values.
> 
> 
> What problems?

See above.
> 
> 
> You ran out of memory.  All your memory is in use by userspace processes.

DOH. the kernel swapped the controller order on me...fstab entries 
referred to the wrong device names...
> 
> 
> 
> Try mounting some swapspace.

swapon -a issued :P
> 
> 
>>Nov  1 03:16:00 spf5-3 kernel: Out of Memory: Killed process 21861 (smtpd).
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>failed at net/ipv4/tcp.c (1284)
>>Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>failed at net/ipv4/tcp.c (1284)
>>Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>net/ipv4/tcp.c (1348)
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>failed at net/ipv4/tcp.c (1284)
>>Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>net/ipv4/tcp.c (1348)
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (flags & MSG_PEEK) 
>>failed at net/ipv4/tcp.c (1284)
>>Nov  1 03:16:00 spf5-3 kernel: recvmsg bug: copied 1E619F78 seq 1E61A378
>>Nov  1 03:16:00 spf5-3 kernel: KERNEL: assertion (tp->copied_seq == 
>>tp->rcv_nxt || (flags & (MSG_PEEK | MSG_TRUNC))) failed at 
>>net/ipv4/tcp.c (1348)
> 
> 
> This is a networking bug.
> 

Yes...it's the same one that won't allow me to use the e100 driver with 
NAPI enabled with or without them sysctl tweaks and the same one that 
forces me to use the tweaks without NAPI enabled for the e100 driver.

With NAPI enabled, I see the problem when under pressure.

FYI, the 2.6.9 kernel is running with NAPI enabled.
