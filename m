From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 63871] New: BUG skbuff_head_cache (Tainted: G        W  
 ): Object padding overwritten
Date: Fri, 1 Nov 2013 15:56:20 -0700
Message-ID: <20131101155620.b4388760cfb8562430e3039c@linux-foundation.org>
References: <bug-63871-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, mikhail.v.gavrilov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56011 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095Ab3KAW4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 18:56:22 -0400
In-Reply-To: <bug-63871-27@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Possible networking memory scribble?

On Sun, 27 Oct 2013 16:01:39 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=63871
> 
>             Bug ID: 63871
>            Summary: BUG skbuff_head_cache (Tainted: G        W   ): Object
>                     padding overwritten
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.11.6
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Slab Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: mikhail.v.gavrilov@gmail.com
>         Regression: No
> 
> Created attachment 112441
>   --> https://bugzilla.kernel.org/attachment.cgi?id=112441&action=edit
> dmesg output
> 
> [12745.265250]
> =============================================================================
> [12745.265254] BUG skbuff_head_cache (Tainted: G        W   ): Object padding
> overwritten
> [12745.265254]
> -----------------------------------------------------------------------------
> 
> [12745.265256] INFO: 0xffff88080c1ef5fe-0xffff88080c1ef5fe. First byte 0x7a
> instead of 0x5a
> [12745.265261] INFO: Allocated in __alloc_skb+0x4e/0x2b0 age=87 cpu=0 pid=10621
> [12745.265265]     __slab_alloc+0x45f/0x526
> [12745.265267]     kmem_cache_alloc_node+0xd8/0x3d0
> [12745.265268]     __alloc_skb+0x4e/0x2b0
> [12745.265270]     sock_alloc_send_pskb+0x27e/0x400
> [12745.265271]     sock_alloc_send_skb+0x15/0x20
> [12745.265274]     __ip_append_data.isra.44+0x5a2/0x9c0
> [12745.265275]     ip_make_skb+0x113/0x160
> [12745.265278]     udp_sendmsg+0x2ba/0xb70
> [12745.265279]     inet_sendmsg+0x117/0x230
> [12745.265280]     sock_sendmsg+0x99/0xd0
> [12745.265281]     SYSC_sendto+0x124/0x1d0
> [12745.265282]     SyS_sendto+0xe/0x10
> [12745.265286]     system_call_fastpath+0x16/0x1b
> [12745.265287] INFO: Freed in kfree_skbmem+0x37/0x90 age=87 cpu=0 pid=10621
> [12745.265289]     __slab_free+0x3a/0x382
> [12745.265290]     kmem_cache_free+0x37a/0x390
> [12745.265291]     kfree_skbmem+0x37/0x90
> [12745.265293]     consume_skb+0x38/0x150
> [12745.265297]     rtl8169_poll+0x508/0x708 [r8169]
> [12745.265298]     net_rx_action+0x172/0x380
> [12745.265300]     __do_softirq+0x107/0x410
> [12745.265302]     call_softirq+0x1c/0x30
> [12745.265304]     do_softirq+0x85/0xc0
> [12745.265305]     local_bh_enable+0xdb/0xf0
> [12745.265307]     ip_finish_output2+0x22d/0x540
> [12745.265308]     ip_fragment+0x7a3/0x9a0
> [12745.265310]     ip_finish_output+0x54f/0x800
> [12745.265311]     ip_output+0x68/0x110
> [12745.265312]     ip_local_out+0x29/0x90
> [12745.265313]     ip_send_skb+0x15/0x50
> [12745.265314] INFO: Slab 0xffffea0020307b00 objects=28 used=28 fp=0x         
> (null) flags=0x5ff00000004080
> [12745.265315] INFO: Object 0xffff88080c1ef3c0 @offset=13248
> fp=0xffff88080c1ec240
> 
> [12745.265317] Bytes b4 ffff88080c1ef3b0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [12745.265318] Object ffff88080c1ef3c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265318] Object ffff88080c1ef3d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265319] Object ffff88080c1ef3e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265320] Object ffff88080c1ef3f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265321] Object ffff88080c1ef400: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265322] Object ffff88080c1ef410: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265322] Object ffff88080c1ef420: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265323] Object ffff88080c1ef430: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265324] Object ffff88080c1ef440: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265325] Object ffff88080c1ef450: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265326] Object ffff88080c1ef460: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265326] Object ffff88080c1ef470: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265327] Object ffff88080c1ef480: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265328] Object ffff88080c1ef490: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [12745.265329] Object ffff88080c1ef4a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b a5  kkkkkkkkkkkkkkk.
> [12745.265330] Redzone ffff88080c1ef4b0: bb bb bb bb bb bb bb bb               
>           ........
> [12745.265331] Padding ffff88080c1ef5f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 7a 5a  ZZZZZZZZZZZZZZzZ
> [12745.265332] CPU: 0 PID: 10621 Comm: transmission-gt Tainted: G    B   W   
> 3.11.6-301.fc20.x86_64+debug #1
> [12745.265333] Hardware name: Gigabyte Technology Co., Ltd. Z87M-D3H/Z87M-D3H,
> BIOS F8 08/03/2013
> [12745.265334]  ffff88080c1ef3c0 ffff880298869760 ffffffff817289cc
> ffff880813901200
> [12745.265337]  ffff8802988697a0 ffffffff811cd4ed 0000000000000010
> ffff880800000001
> [12745.265339]  ffff88080c1ef5ff ffff880813901200 000000000000005a
> ffff88080c1ef3c0
> [12745.265342] Call Trace:
> [12745.265344]  [<ffffffff817289cc>] dump_stack+0x54/0x74
> [12745.265348]  [<ffffffff811cd4ed>] print_trailer+0x14d/0x200
> [12745.265350]  [<ffffffff811cd6df>] check_bytes_and_report+0xcf/0x110
> [12745.265353]  [<ffffffff811ce628>] check_object+0xa8/0x250
> [12745.265355]  [<ffffffff815df9fe>] ? __alloc_skb+0x4e/0x2b0
> [12745.265358]  [<ffffffff81726165>] alloc_debug_processing+0x76/0x118
> [12745.265360]  [<ffffffff81726e3a>] __slab_alloc+0x45f/0x526
> [12745.265361]  [<ffffffff811d462d>] ? __kmalloc_node_track_caller+0x1dd/0x420
> [12745.265363]  [<ffffffff815df9fe>] ? __alloc_skb+0x4e/0x2b0
> [12745.265365]  [<ffffffff815df241>] ? __kmalloc_reserve.isra.25+0x31/0x90
> [12745.265367]  [<ffffffff815df9fe>] ? __alloc_skb+0x4e/0x2b0
> [12745.265368]  [<ffffffff811d0d98>] kmem_cache_alloc_node+0xd8/0x3d0
> [12745.265370]  [<ffffffff815df9fe>] __alloc_skb+0x4e/0x2b0
> [12745.265372]  [<ffffffff815d8de4>] sock_wmalloc+0x34/0x90
> [12745.265375]  [<ffffffff8163a803>] __ip_append_data.isra.44+0x7c3/0x9c0
> [12745.265377]  [<ffffffff816385a0>] ? ip_reply_glue_bits+0x60/0x60
> [12745.265378]  [<ffffffff816384aa>] ? ip_setup_cork+0x7a/0x110
> [12745.265380]  [<ffffffff8163c4f3>] ip_make_skb+0x113/0x160
> [12745.265382]  [<ffffffff816385a0>] ? ip_reply_glue_bits+0x60/0x60
> [12745.265384]  [<ffffffff8162e400>] ? __ip_route_output_key+0x360/0xb20
> [12745.265386]  [<ffffffff81669faa>] udp_sendmsg+0x2ba/0xb70
> [12745.265388]  [<ffffffff816385a0>] ? ip_reply_glue_bits+0x60/0x60
> [12745.265390]  [<ffffffff81676c75>] ? inet_sendmsg+0x5/0x230
> [12745.265391]  [<ffffffff81676d87>] inet_sendmsg+0x117/0x230
> [12745.265392]  [<ffffffff81676c75>] ? inet_sendmsg+0x5/0x230
> [12745.265393]  [<ffffffff815d52d9>] sock_sendmsg+0x99/0xd0
> [12745.265395]  [<ffffffff81668e09>] ? udp_poll+0xe9/0x230
> [12745.265397]  [<ffffffff81668d25>] ? udp_poll+0x5/0x230
> [12745.265398]  [<ffffffff815d5834>] SYSC_sendto+0x124/0x1d0
> [12745.265402]  [<ffffffff812111e9>] ? fget_light+0xf9/0x510
> [12745.265405]  [<ffffffff8137a8ce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [12745.265406]  [<ffffffff815d699e>] SyS_sendto+0xe/0x10
> [12745.265409]  [<ffffffff8173bcd9>] system_call_fastpath+0x16/0x1b
> [12745.265410] FIX skbuff_head_cache: Restoring
> 0xffff88080c1ef5fe-0xffff88080c1ef5fe=0x5a
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
