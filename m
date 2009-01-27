From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Deadlock with icmpv6fuzz
Date: Tue, 27 Jan 2009 08:53:56 +0100
Message-ID: <20090127075356.GA6255@alice>
References: <20090120204743.GA25797@alice> <20090126.213112.197185044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53486 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751697AbZA0HyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 02:54:00 -0500
Content-Disposition: inline
In-Reply-To: <20090126.213112.197185044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller (davem@davemloft.net) wrote:
> From: Eric Sesterhenn <snakebyte@gmx.de>
> Date: Tue, 20 Jan 2009 21:47:43 +0100
> 
> > Kernel is current -git
> 
> Weird trace.
> 
> I can't figure out what would cause it.
> 
> Is the program counter on the skb_push() call
> that is part of that:
> 
> 	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, ipv6_optlen(opt));
> 
> line it seems to be stuck on?

With current -git i get a different issue (and the box stays alive)

[  233.207012] skb_under_panic: text:c071d3ab len:2361 put:864
head:cba29a40 data:cba29798 tail:0xcba29af8 end:0xcba29b00 dev:<NULL>
[  233.223482] ------------[ cut here ]------------
[  233.223660] kernel BUG at net/core/skbuff.c:143!
[  233.223789] invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[  233.224086] last sysfs file: /sys/block/ram9/range
[  233.224086] Modules linked in:
[  233.224086] 
[  233.224086] Pid: 5020, comm: icmpv6fuzz Not tainted
(2.6.29-rc2-00362-g884f64f #224) System Name
[  233.224086] EIP: 0060:[<c0691721>] EFLAGS: 00010246 CPU: 0
[  233.224086] EIP is at skb_under_panic+0x3f/0x46
[  233.224086] EAX: 00000088 EBX: c098dc65 ECX: 00000003 EDX: c0124782
[  233.224086] ESI: 00000000 EDI: cbb9accc EBP: cbb9ac68 ESP: cbb9ac3c
[  233.224086]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[  233.224086] Process icmpv6fuzz (pid: 5020, ti=cbb9a000 task=cbb25c50
task.ti=cbb9a000)
[  233.224086] Stack:
[  233.224086]  c09d333e c071d3ab 00000939 00000360 cba29a40 cba29798
cba29af8 cba29b00
[  233.224086]  c098dc65 cef549a0 cbb7903c cbb9ac74 c06929ce cbb9acd3
cbb9ac90 c071d3ab
[  233.224086]  0000003c cbb9ac90 cef549a0 cedc31b4 cbb9accc cbb9aca0
c071d3fd cbb7903c
[  233.224086] Call Trace:
[  233.224086]  [<c071d3ab>] ? ipv6_push_exthdr+0x26/0x55
[  233.224086]  [<c06929ce>] ? skb_push+0x2c/0x35
[  233.224086]  [<c071d3ab>] ? ipv6_push_exthdr+0x26/0x55
[  233.224086]  [<c071d3fd>] ? ipv6_push_frag_opts+0x23/0x29
[  233.224086]  [<c07019c2>] ? ip6_push_pending_frames+0x1b2/0x39b
[  233.224086]  [<c07144e9>] ? rawv6_sendmsg+0xa84/0xb17
[  233.224086]  [<c013eee5>] ? put_lock_stats+0xd/0x21
[  233.224086]  [<c013eee5>] ? put_lock_stats+0xd/0x21
[  233.224086]  [<c013ef98>] ? lock_release_holdtime+0x9f/0xa7
[  233.224086]  [<c06db73a>] ? inet_sendmsg+0x40/0x4d
[  233.224086]  [<c068d981>] ? sock_sendmsg+0xce/0xe5
[  233.224086]  [<c013eee5>] ? put_lock_stats+0xd/0x21
[  233.224086]  [<c0134344>] ? autoremove_wake_function+0x0/0x35
[  233.224086]  [<c014306f>] ? lock_release_non_nested+0xb0/0x1f8
[  233.224086]  [<c017cf8d>] ? might_fault+0x4f/0x8b
[  233.224086]  [<c017cf8d>] ? might_fault+0x4f/0x8b
[  233.224086]  [<c068e2e1>] ? sys_sendto+0xa9/0xc8
[  233.224086]  [<c013eee5>] ? put_lock_stats+0xd/0x21
[  233.224086]  [<c013ef98>] ? lock_release_holdtime+0x9f/0xa7
[  233.224086]  [<c07b2507>] ? sub_preempt_count+0xc0/0xd1
[  233.224086]  [<c013eee5>] ? put_lock_stats+0xd/0x21
[  233.224086]  [<c013ef98>] ? lock_release_holdtime+0x9f/0xa7
[  233.224086]  [<c014306f>] ? lock_release_non_nested+0xb0/0x1f8
[  233.224086]  [<c017cf8d>] ? might_fault+0x4f/0x8b
[  233.224086]  [<c068ea7d>] ? sys_socketcall+0xeb/0x180
[  233.224086]  [<c0102ea1>] ? sysenter_do_call+0x12/0x31
[  233.224086] Code: 0f 45 de 53 ff b0 94 00 00 00 ff b0 90 00 00 00 ff
b0 9c 00 00 00 ff b0 98 00 00 00 52 ff 70 50 51 68 3e 33 9d c0 e8 6f 30
a9 ff <0f> 0b 83 c4 24 eb fe 55 89 e5 56 53 0f 1f 44 00 00 8b 70 14 bb 
[  233.224086] EIP: [<c0691721>] skb_under_panic+0x3f/0x46 SS:ESP
0068:cbb9ac3c
[  233.346932] ---[ end trace a3c25240b047560e ]---

But the callsite stays the same

0xc071d3ab is in ipv6_push_exthdr (net/ipv6/exthdrs.c:700).
695		*proto = NEXTHDR_ROUTING;
696	}
697	
698	static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8
type, struct ipv6_opt_hdr *opt)
699	{
700		struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr
*)skb_push(skb, ipv6_optlen(opt));
701	
702		memcpy(h, opt, ipv6_optlen(opt));
703		h->nexthdr = *proto;
704		*proto = type;

Greetings, Eric
