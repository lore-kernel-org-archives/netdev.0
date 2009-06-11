From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] fib_tries related Oops in 2.6.30
Date: Thu, 11 Jun 2009 16:39:57 +0200
Message-ID: <4A31173D.6010504@gmail.com>
References: <3d0408630906100905l5750a20aq781780fe38fccf6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Robert Olsson <robert.olsson@its.uu.se>
To: Yan Zheng <zheng.yan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:40940 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbZFKOkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 10:40:23 -0400
In-Reply-To: <3d0408630906100905l5750a20aq781780fe38fccf6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc Robert Olsson.

Jarek P.

Yan Zheng wrote, On 06/10/2009 06:05 PM:

> Hello,
> 
> I pull linux-2.6.30 from linus-2.6 git tree. I got following oops
> immediately after boot.
> 
> # uname -a
> Linux zhyan-cn 2.6.30 #1 SMP PREEMPT Wed Jun 10 23:37:22 CST 2009 i686
> i686 i386 GNU/Linux
> 
> ---
> BUG: sleeping function called from invalid context at
> /mnt/sda7/linux-2.6/mm/slub.c:1598
> in_atomic(): 1, irqs_disabled(): 0, pid: 2286, name: NetworkManager
> Pid: 2286, comm: NetworkManager Not tainted 2.6.30 #1
> Call Trace:
>  [<c042568c>] __might_sleep+0xfc/0x103
>  [<c049bb79>] __kmalloc+0x7c/0x132
>  [<c0697be5>] ? tnode_new+0x27/0x69
>  [<c0697be5>] tnode_new+0x27/0x69
>  [<c0697d36>] resize+0x94/0x666
>  [<c049ac13>] ? __slab_alloc+0xc2/0x4b3
>  [<c0697be5>] ? tnode_new+0x27/0x69
>  [<c049bc23>] ? __kmalloc+0x126/0x132
>  [<c0698384>] trie_rebalance+0x7c/0xde
>  [<c0698d77>] fn_trie_insert+0x644/0x6d6
>  [<c0427da7>] ? try_to_wake_up+0x2c4/0x2ce
>  [<c0427dbc>] ? default_wake_function+0xb/0xd
>  [<c069402e>] fib_magic+0x99/0xa8
>  [<c069412c>] fib_add_ifaddr+0xef/0x111
>  [<c0694178>] fib_inetaddr_event+0x2a/0x1a9
>  [<c06cd5a9>] notifier_call_chain+0x2b/0x4a
>  [<c0444189>] __blocking_notifier_call_chain+0x37/0x4c
>  [<c04441aa>] blocking_notifier_call_chain+0xc/0xe
>  [<c068d8f4>] __inet_insert_ifa+0xf9/0x104
>  [<c068eb28>] inet_rtm_newaddr+0x16f/0x177
>  [<c068e9b9>] ? inet_rtm_newaddr+0x0/0x177
>  [<c065218c>] rtnetlink_rcv_msg+0x196/0x1b0
>  [<c0651ff6>] ? rtnetlink_rcv_msg+0x0/0x1b0
>  [<c065fbac>] netlink_rcv_skb+0x30/0x78
>  [<c0651fee>] rtnetlink_rcv+0x1c/0x24
>  [<c065f78e>] netlink_unicast+0xee/0x144
>  [<c065fa27>] netlink_sendmsg+0x243/0x250
>  [<c063d1f4>] __sock_sendmsg+0x45/0x4e
>  [<c063d978>] sock_sendmsg+0xb8/0xce
>  [<c044072b>] ? autoremove_wake_function+0x0/0x33
>  [<c044072b>] ? autoremove_wake_function+0x0/0x33
>  [<c044072b>] ? autoremove_wake_function+0x0/0x33
>  [<c0523aa7>] ? copy_from_user+0x34/0x11b
>  [<c0644ba4>] ? verify_iovec+0x40/0x70
>  [<c063dacd>] sys_sendmsg+0x13f/0x192
>  [<c063e67a>] ? sys_recvmsg+0x16d/0x17a
>  [<c041f6b4>] ? kunmap_atomic+0x8b/0xa3
>  [<c0489a88>] ? do_wp_page+0x515/0x5ac
>  [<c044072b>] ? autoremove_wake_function+0x0/0x33
>  [<c041af58>] ? paravirt_get_lazy_mode+0xe/0x1b
>  [<c041b128>] ? arch_flush_lazy_mmu_mode+0x47/0x5b
>  [<c041f799>] ? kmap_atomic_prot+0xcd/0xeb
>  [<c048af8c>] ? handle_mm_fault+0x58d/0x5e8
>  [<c063eb09>] sys_socketcall+0x153/0x183
>  [<c0403298>] sysenter_do_call+0x12/0x2d
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


