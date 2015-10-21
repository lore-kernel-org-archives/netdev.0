From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106361] New: Kernel bug: Thread aborts unexpectedly
 when sending UDP message
Date: Wed, 21 Oct 2015 09:29:42 -0700
Message-ID: <1445444982.22974.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021090306.7f15cf94@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luckythree999@163.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35969 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbbJUQ3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 12:29:44 -0400
Received: by pacfv9 with SMTP id fv9so61589727pac.3
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 09:29:43 -0700 (PDT)
In-Reply-To: <20151021090306.7f15cf94@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-21 at 09:03 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Tue, 20 Oct 2015 15:20:24 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 106361] New: Kernel bug: Thread aborts unexpectedly when sending UDP message
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=106361
> 
>             Bug ID: 106361
>            Summary: Kernel bug: Thread aborts unexpectedly when sending
>                     UDP message
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.3.0
>           Hardware: ARM
>                 OS: Linux
>               Tree: PREEMPT_RT
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: luckythree999@163.com
>         Regression: No
> 
> I run into a kernel bug at ARM Linux, during UDP usage with our application
> (ENB03_BPU_APP_1) with Multithreading.
> In my application, One Thread aborts unexpectedly when sending UDP message.
> And I am repeatedly getting this, and it will happen within 3-12 hours of
> running on a system doing primarily only UDP send/receive activity.
> 
> 
> 1> And Environment :
>    1.1> root@tci6614-evm:~# uname -a
>     Linux tci6614-evm 3.3.0-dirty #20 PREEMPT Mon May 19 14:50:04 CST 2014
> armv7l unknown
> 
>    1.2> root@tci6614-evm:~# cat /proc/version 
>     Linux version 3.3.0-dirty (root@cpit-desktop) (gcc version 4.3.3 (Sourcery
> G++ Lite 2009q1-203) ) #20 PREEMPT Mon May 19 14:50:04 CST 2014
> 
> 
> 
> 2>  This is the stack trace:
> .................................................................................................................
> skb_under_panic: text:c0269e24 len:392 put:14 head:d3cea000 data:d3ce9ff4
> tail:0xd3cea17c end:0xd3cea340 dev:eth0
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:147!
> Internal error: Oops - BUG: 0 [#1] PREEMPT
> Modules linked in: drv_fpga_module(O)
> CPU: 0    Tainted: G           O  (3.3.0-dirty #20)
> PC is at skb_push+0x7c/0x84
> LR is at skb_push+0x7c/0x84
> pc : [<c02496f0>]    lr : [<c02496f0>]    psr: 60000013
> sp : d4afbc28  ip : c04c7770  fp : d62f2a54
> r10: 00000000  r9 : d62f2a50  r8 : d6008800
> r7 : d3cea000  r6 : d3ce9ff4  r5 : d3cea340  r4 : d6008800
> r3 : 20000093  r2 : 60000013  r1 : 60000013  r0 : 00000078
> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 10c5387d  Table: 94960019  DAC: 00000015
> Process ENB03_BPU_APP_1 (pid: 1117, stack limit = 0xd4afa2e8)
> Stack: (0xd4afbc28 to 0xd4afc000)
> bc20:                   d3cea000 d3ce9ff4 d3cea17c d3cea340 d6008800 d3cea002
> bc40: d604c908 00000800 d6325a80 00000000 d62f2a54 c0269e24 d62f2a00 d6325a80
> bc60: 0000156c 0000017a d6008800 c0260160 00000000 0000017a c02884bc 0000016c
> bc80: d6325a80 d62f2a00 d62be900 d6325a80 00000000 d4901e40 0000000e c028b2c0
> bca0: d6008800 d6325a80 d6325a80 d4afbd8c d62be900 00000000 d6325a80 00000158
> bcc0: d4afbd8c c028a678 d3cea024 c028a684 d3cea024 c02aaef4 00000000 00000158
> bce0: d4afbf5c d62be900 00000150 00000000 d6325a80 00000000 d4afbd8c c02ad378
> bd00: 00000158 00000008 d4afbdac d4afbdbc 00000000 c01e07d0 00000001 d4afbdac
> bd20: 00000000 00000000 00000000 3232a8c0 3232a8c0 d2e6a8c0 00003930 00000000
> bd40: c0289af0 d62beaa8 00000000 00000000 00000000 00000000 00000000 d4afbdc0
> bd60: 00000001 d5c9e108 d4afbf74 00000001 00000001 c018c0ac 00000000 d63e6a40
> bd80: 00000000 d63e6a40 00000001 00000000 00000000 00000000 04110000 00000000
> bda0: d2e6a8c0 3232a8c0 44e03930 3232a8c0 00000000 00000000 00000000 00000000
> bdc0: 00000003 d62be900 d4afbe00 d4afbf5c 00000150 d4afbe00 d4afa000 00000010
> bde0: 7b26cc44 c02b40a0 00000000 00000000 d64f1480 00000150 d4afbe00 c02416a4
> be00: 00000000 fffffffe 00000000 00000001 ffffffff 00000000 00000000 00000000
> be20: 00000000 00000000 d78a7500 c0053244 00000000 00000000 d78a7500 d78a7500
> be40: d4afbe80 d5d5c000 d5d5c000 d5d5c000 d4afbeec c035f314 d5d6bf38 d4afbf30
> be60: c04c9b94 00000000 c04dd658 c04c5144 c04be38c c036a8fc c04be0ec c04ca508
> be80: d4afbf30 c0049d34 00000000 00000150 d64f1480 c004a2d8 00000000 d4afbf5c
> bea0: d4afbf80 00000000 008364f4 d64f1480 d4afbedc 00000000 008364f4 d4afbedc
> bec0: 00000150 d64f1480 d4afbedc 00000000 008364f4 c0241dec 004c4b40 39300002
> bee0: 3232a8c0 00000000 00000000 c035eac8 00000000 00000001 004c4b40 00000000
> bf00: 00000000 00000000 00000000 00000000 00000001 c004a47c 00000000 00000000
> bf20: c04f1fb8 00000000 004c4b40 00000000 d4afbf31 00000000 00000000 00000000
> bf40: 9a4359e0 000007db 9a4359e0 000007db c00499ac c04c9b88 00000000 d4afbedc
> bf60: 00000010 d4afbf78 00000001 00000000 00000000 00000000 9a252ae8 00000150
> bf80: 00000001 00000000 7b26dc8c 008364f4 00000010 00397a08 00000122 c0013bc8
> bfa0: 00000000 c0013a20 008364f4 00000010 0000000a 9a252ae8 00000150 00000000
> bfc0: 008364f4 00000010 00397a08 00000122 003d0f00 beb76bd8 00000000 7b26cc44
> bfe0: 00000000 7b26cc10 00399f58 0039acf4 80000010 0000000a 00000000 00000000
> [<c02496f0>] (skb_push+0x7c/0x84) from [<c0269e24>] (eth_header+0x1c/0xb8)
> [<c0269e24>] (eth_header+0x1c/0xb8) from [<c0260160>]
> (neigh_resolve_output+0x13c/0x1ac)
> [<c0260160>] (neigh_resolve_output+0x13c/0x1ac) from [<c028b2c0>]
> (ip_finish_output+0x238/0x30c)
> [<c028b2c0>] (ip_finish_output+0x238/0x30c) from [<c028a678>]
> (ip_local_out+0x28/0x2c)
> [<c028a678>] (ip_local_out+0x28/0x2c) from [<c028a684>] (ip_send_skb+0x8/0x58)
> [<c028a684>] (ip_send_skb+0x8/0x58) from [<c02aaef4>] (udp_send_skb+0xe4/0x34c)
> [<c02aaef4>] (udp_send_skb+0xe4/0x34c) from [<c02ad378>]
> (udp_sendmsg+0x634/0x750)
> [<c02ad378>] (udp_sendmsg+0x634/0x750) from [<c02b40a0>]
> (inet_sendmsg+0x4c/0x6c)
> [<c02b40a0>] (inet_sendmsg+0x4c/0x6c) from [<c02416a4>]
> (sock_sendmsg+0x98/0xb8)
> [<c02416a4>] (sock_sendmsg+0x98/0xb8) from [<c0241dec>] (sys_sendto+0xb4/0xd8)
> [<c0241dec>] (sys_sendto+0xb4/0xd8) from [<c0013a20>]
> (ret_fast_syscall+0x0/0x30)
> Code: e98d4040 e58d500c e58d4010 eb045164 (e7f001f2) 
> ---[ end trace cfb1d2ec7e84e37e ]---
> ..............................................................................................................
> 

Very probably a driver bug.

dev->hard_header_len not properly setup.
