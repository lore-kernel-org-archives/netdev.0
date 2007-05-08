From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8450] New: ip6sic causes bug during interrupt
 handling
Date: Tue, 8 May 2007 02:55:27 -0700
Message-ID: <20070508025527.f94b3ae2.akpm@linux-foundation.org>
References: <200705080947.l489lkG3007380@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, snakebyte@gmx.de,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:50110 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934778AbXEHJ4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 05:56:34 -0400
In-Reply-To: <200705080947.l489lkG3007380@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007 02:47:46 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8450
> 
>            Summary: ip6sic causes bug during interrupt handling
>     Kernel Version: 2.6.21-ga989705c and earlier
>             Status: NEW
>           Severity: normal
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: snakebyte@gmx.de
> 
> 
> Most recent kernel where this bug did *NOT* occur: had this since 2.6.20, didnt
> test earlier versions
> Distribution: gentoo
> Hardware Environment: p3
> Software Environment: gcc 4.1.2
> Problem Description:
> 
> running ip6sic with the following seed
> 
> ip6sic -i lo -d ::1 -p 2000 -r 32321
> 
> causes this oops
> 
> [   69.293000] Oops: 0000 [#1]
> [   69.293000] PREEMPT 
> [   69.293000] Modules linked in:
> [   69.293000] CPU:    0
> [   69.293000] EIP:    0060:[<c0548b76>]    Not tainted VLI
> [   69.293000] EFLAGS: 00010282   (2.6.21-ga989705c #7)
> [   69.293000] EIP is at ipv6_hop_jumbo+0x26/0x180
> [   69.293000] eax: 00000000   ebx: ce61bc08   ecx: 00000001   edx: 00000103
> [   69.293000] esi: ce750166   edi: 000000fd   ebp: c0773ed8   esp: c0773ec0
> [   69.293000] ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> [   69.293000] Process ip6sic (pid: 4607, ti=c0773000 task=cf332070
> task.ti=cf002000)
> [   69.293000] Stack: c06c4ccc 000000fb c0773ef8 00000246 c071ae9c 0000002a
> c0773f08 c054837f 
> [   69.293000]        ce61bc08 c055a39d c0773f38 c071ae94 ce61bc08 ce75013c
> 00000306 ce61bc08 
> [   69.293000]        c0773f38 ce61bc44 c0773f18 c0548ed1 00000000 cf8bdd84
> c0773f48 c052807e 
> [   69.293000] Call Trace:
> [   69.293000]  [<c010485a>] show_trace_log_lvl+0x1a/0x30
> [   69.293000]  [<c0104919>] show_stack_log_lvl+0xa9/0xd0
> [   69.293000]  [<c0104b5b>] show_registers+0x21b/0x3a0
> [   69.293000]  [<c0104de3>] die+0x103/0x260
> [   69.293000]  [<c01162c2>] do_page_fault+0x2d2/0x610
> [   69.293000]  [<c05a5732>] error_code+0x6a/0x70
> [   69.293000]  [<c054837f>] ip6_parse_tlv+0xef/0x130
> [   69.293000]  [<c0548ed1>] ipv6_parse_hopopts+0x41/0xb0
> [   69.293000]  [<c052807e>] ipv6_rcv+0x1be/0x370
> [   69.293000]  [<c04b32fb>] netif_receive_skb+0x21b/0x2b0
> [   69.293000]  [<c04b52d2>] process_backlog+0x82/0xf0
> [   69.293000]  [<c04b558b>] net_rx_action+0xab/0x1c0
> [   69.293000]  [<c0120cd2>] __do_softirq+0x72/0xe0
> [   69.293000]  [<c010627a>] do_softirq+0x8a/0xf0
> [   69.293000]  [<c0120fd5>] local_bh_enable+0xa5/0x160
> [   69.293000]  [<c04b5738>] dev_queue_xmit+0x98/0x330
> [   69.293000]  [<c055a678>] packet_sendmsg+0x208/0x260
> [   69.293000]  [<c04a8594>] sock_sendmsg+0xc4/0xf0
> [   69.293000]  [<c04a889f>] sys_sendto+0xbf/0xe0
> [   69.293000]  [<c04a97c7>] sys_socketcall+0x187/0x260
> [   69.293000]  [<c0104132>] sysenter_past_esp+0x5f/0x99
> [   69.293000]  =======================
> [   69.293000] Code: 90 8d 74 26 00 55 89 e5 56 53 83 ec 10 8b 18 8b 4b 78 8d
> 34 11 80 7e 01 04 74 3b a1 10 3c 72 c0 85 c0 0f 85 7d 00 00 00 8b 43 1c <8b>
> 80 8c 00 00 00 85 c0 74 09 8b 80 38 01 00 00 ff 40 08 a1 e4 
> [   69.293000] EIP: [<c0548b76>] ipv6_hop_jumbo+0x26/0x180 SS:ESP
> 0068:c0773ec0
> [   69.305000] Kernel panic - not syncing: Fatal exception in interrupt
> 
> 
> 
> Steps to reproduce:
