From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Slab Corruption with ipv6 and tcp6fuzz
Date: Thu, 24 Apr 2008 16:27:27 +0200
Message-ID: <20080424142727.GA24025@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:56096 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751623AbYDXO1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 10:27:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

i found some local ivp6 network fuzzing tools from the bsd folks
today and wanted to add them to my testmachine. When
trying one of them (running with user privs) it gave me slab corruption errors.
Running http://clem1.be/lf6/tcp6fuzz.c 1 to 5 times
always results in errors, strangely using the same seed twice
in a row doesnt trigger the warnings again.

If there is any more info i can provide please let me know.

A sample of the warnings follows:

[   57.315914] process `tcp6fuzz' is using obsolete setsockopt SO_BSDCOMPAT
[   57.810370] sock_set_timeout: `tcp6fuzz' (pid 3721) tries to set negative timeout
[  215.102729] =============================================================================
[  215.102786] BUG skbuff_head_cache: Invalid object pointer 0xccd2b520
[  215.102810] -----------------------------------------------------------------------------
[  215.102816] 
[  215.102840] INFO: Slab 0xc119c560 used=10 fp=0x00000000 flags=0x40000083
[  215.102868] Pid: 0, comm: swapper Not tainted 2.6.25-03562-g3dc5063 #23
[  215.102880]  [<c0177b57>] slab_err+0x47/0x50
[  215.102978]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
[  215.102994]  [<c0177c92>] ? check_slab+0x52/0x80
[  215.103010]  [<c0179405>] __slab_free+0x1d5/0x2d0
[  215.103024]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
[  215.103039]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.103063]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.103078]  [<c05d91dc>] __kfree_skb+0x3c/0x90
[  215.103090]  [<c05d9249>] kfree_skb+0x19/0x30
[  215.103103]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
[  215.103128]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.103161]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.103177]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.103191]  [<c012b075>] ? local_bh_enable_ip+0x85/0xf0
[  215.103220]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.103245]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.103260]  [<c0146721>] ? trace_hardirqs_on+0x81/0x150
[  215.103275]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.103289]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.103317]  [<c014424d>] ? put_lock_stats+0xd/0x30
[  215.103333]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.103349]  [<c0706615>] ? _spin_lock_nested+0x65/0x80
[  215.103377]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.103391]  [<c0674f57>] tcp_v6_rcv+0x627/0x710
[  215.103404]  [<c06809c0>] ? ip6t_hook+0x0/0x30
[  215.103418]  [<c05f3c89>] ? nf_iterate+0x59/0x80
[  215.103448]  [<c0653ff2>] ip6_input_finish+0xc2/0x2a0
[  215.103465]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.103479]  [<c06541ef>] ip6_input+0x1f/0x60
[  215.103491]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.103505]  [<c0654464>] ipv6_rcv+0x194/0x2e0
[  215.103518]  [<c0654290>] ? ip6_rcv_finish+0x0/0x40
[  215.103532]  [<c06542d0>] ? ipv6_rcv+0x0/0x2e0
[  215.103545]  [<c05de7f0>] netif_receive_skb+0x280/0x2f0
[  215.103560]  [<c05e1336>] process_backlog+0x76/0xd0
[  215.103576]  [<c05e0c90>] net_rx_action+0x120/0x1a0
[  215.103589]  [<c012ac92>] __do_softirq+0x62/0xc0
[  215.103602]  [<c010676a>] do_softirq+0x8a/0xd0
[  215.103618]  [<c0155f80>] ? handle_level_irq+0x0/0xe0
[  215.103634]  [<c012abc6>] irq_exit+0x86/0x90
[  215.103647]  [<c010684a>] do_IRQ+0x9a/0x100
[  215.103659]  [<c0706e49>] ? _spin_unlock_irqrestore+0x39/0x70
[  215.103677]  [<c01047f2>] common_interrupt+0x2e/0x34
[  215.103691]  [<c0140000>] ? sysfs_override_clocksource+0x70/0x100
[  215.103706]  [<c04b6d42>] ? acpi_idle_enter_simple+0x18a/0x1fc
[  215.103739]  [<c058decd>] cpuidle_idle_call+0x5d/0xb0
[  215.103760]  [<c058de70>] ? cpuidle_idle_call+0x0/0xb0
[  215.103775]  [<c0102838>] cpu_idle+0x38/0xa0
[  215.103787]  [<c06f94cc>] rest_init+0x5c/0x60
[  215.103811]  =======================
[  215.103819] FIX skbuff_head_cache: Object at 0xccd2b520 not freed
[  215.108749] =============================================================================
[  215.108796] BUG skbuff_head_cache: Invalid object pointer 0xcb13a820
[  215.108820] -----------------------------------------------------------------------------
[  215.108826] 
[  215.108851] INFO: Slab 0xc1164740 used=5 fp=0xcb13a600 flags=0x40000083
[  215.108879] Pid: 3172, comm: dd Not tainted 2.6.25-03562-g3dc5063 #23
[  215.108896]  [<c0177b57>] slab_err+0x47/0x50
[  215.108935]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
[  215.108951]  [<c0177c92>] ? check_slab+0x52/0x80
[  215.108966]  [<c0179405>] __slab_free+0x1d5/0x2d0
[  215.108981]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
[  215.108995]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.109021]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.109035]  [<c05d91dc>] __kfree_skb+0x3c/0x90
[  215.109048]  [<c05d9249>] kfree_skb+0x19/0x30
[  215.109060]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
[  215.109086]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.109120]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.109136]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.109151]  [<c012b075>] ? local_bh_enable_ip+0x85/0xf0
[  215.109181]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.109209]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.109224]  [<c0146721>] ? trace_hardirqs_on+0x81/0x150
[  215.109239]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.109253]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.109281]  [<c014424d>] ? put_lock_stats+0xd/0x30
[  215.109296]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.109312]  [<c0706615>] ? _spin_lock_nested+0x65/0x80
[  215.109337]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.109352]  [<c0674f57>] tcp_v6_rcv+0x627/0x710
[  215.109365]  [<c06809c0>] ? ip6t_hook+0x0/0x30
[  215.109379]  [<c05f3c89>] ? nf_iterate+0x59/0x80
[  215.109412]  [<c0653ff2>] ip6_input_finish+0xc2/0x2a0
[  215.109428]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.109443]  [<c06541ef>] ip6_input+0x1f/0x60
[  215.109455]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.109469]  [<c0654464>] ipv6_rcv+0x194/0x2e0
[  215.109481]  [<c0654290>] ? ip6_rcv_finish+0x0/0x40
[  215.109495]  [<c06542d0>] ? ipv6_rcv+0x0/0x2e0
[  215.109508]  [<c05de7f0>] netif_receive_skb+0x280/0x2f0
[  215.109524]  [<c05e1336>] process_backlog+0x76/0xd0
[  215.109540]  [<c05e0c90>] net_rx_action+0x120/0x1a0
[  215.109554]  [<c012ac92>] __do_softirq+0x62/0xc0
[  215.109567]  [<c010676a>] do_softirq+0x8a/0xd0
[  215.109583]  [<c0155f80>] ? handle_level_irq+0x0/0xe0
[  215.109599]  [<c012abc6>] irq_exit+0x86/0x90
[  215.109612]  [<c010684a>] do_IRQ+0x9a/0x100
[  215.109625]  [<c01047f2>] common_interrupt+0x2e/0x34
[  215.109639]  [<c0147cff>] ? lock_acquire+0x8f/0xa0
[  215.109654]  [<c01959e0>] ? mnt_want_write+0x20/0x90
[  215.109677]  [<c0706669>] _spin_lock+0x39/0x70
[  215.109690]  [<c01959e0>] ? mnt_want_write+0x20/0x90
[  215.109704]  [<c01959e0>] mnt_want_write+0x20/0x90
[  215.109717]  [<c0191a79>] file_update_time+0x39/0xd0
[  215.109744]  [<c018413a>] pipe_write+0x21a/0x450
[  215.109772]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.109788]  [<c017d55c>] do_sync_write+0xcc/0x110
[  215.109802]  [<c0138a80>] ? autoremove_wake_function+0x0/0x50
[  215.109827]  [<c01b1c9e>] ? dnotify_parent+0x6e/0x80
[  215.109850]  [<c0706d47>] ? _spin_unlock+0x27/0x50
[  215.109867]  [<c017dd99>] vfs_write+0x99/0x130
[  215.109879]  [<c017d490>] ? do_sync_write+0x0/0x110
[  215.109893]  [<c017e38d>] sys_write+0x3d/0x70
[  215.109906]  [<c0103d75>] sysenter_past_esp+0x6a/0xb1
[  215.109920]  =======================
[  215.109928] FIX skbuff_head_cache: Object at 0xcb13a820 not freed
[  215.116324] =============================================================================
[  215.116372] BUG skbuff_head_cache: Invalid object pointer 0xccbf10a0
[  215.116396] -----------------------------------------------------------------------------
[  215.116401] 
[  215.116426] INFO: Slab 0xc1199e20 used=10 fp=0x00000000 flags=0x40000083
[  215.116455] Pid: 3172, comm: dd Not tainted 2.6.25-03562-g3dc5063 #23
[  215.116467]  [<c0177b57>] slab_err+0x47/0x50
[  215.116506]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
[  215.116522]  [<c0177c92>] ? check_slab+0x52/0x80
[  215.116537]  [<c0179405>] __slab_free+0x1d5/0x2d0
[  215.116553]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
[  215.116567]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.116592]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.116606]  [<c05d91dc>] __kfree_skb+0x3c/0x90
[  215.116619]  [<c05d9249>] kfree_skb+0x19/0x30
[  215.116631]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
[  215.116657]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.116693]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.116709]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.116724]  [<c012b075>] ? local_bh_enable_ip+0x85/0xf0
[  215.116753]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.116781]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.116796]  [<c0146721>] ? trace_hardirqs_on+0x81/0x150
[  215.116811]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.116826]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.116855]  [<c014424d>] ? put_lock_stats+0xd/0x30
[  215.116870]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.116886]  [<c0706615>] ? _spin_lock_nested+0x65/0x80
[  215.116913]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.116928]  [<c0674f57>] tcp_v6_rcv+0x627/0x710
[  215.116941]  [<c06809c0>] ? ip6t_hook+0x0/0x30
[  215.116955]  [<c05f3c89>] ? nf_iterate+0x59/0x80
[  215.116988]  [<c0653ff2>] ip6_input_finish+0xc2/0x2a0
[  215.117006]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.117021]  [<c06541ef>] ip6_input+0x1f/0x60
[  215.117033]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.117047]  [<c0654464>] ipv6_rcv+0x194/0x2e0
[  215.117059]  [<c0654290>] ? ip6_rcv_finish+0x0/0x40
[  215.117073]  [<c06542d0>] ? ipv6_rcv+0x0/0x2e0
[  215.117087]  [<c05de7f0>] netif_receive_skb+0x280/0x2f0
[  215.117102]  [<c05e1336>] process_backlog+0x76/0xd0
[  215.117118]  [<c05e0c90>] net_rx_action+0x120/0x1a0
[  215.117131]  [<c012ac92>] __do_softirq+0x62/0xc0
[  215.117145]  [<c010676a>] do_softirq+0x8a/0xd0
[  215.117161]  [<c0155f80>] ? handle_level_irq+0x0/0xe0
[  215.117178]  [<c012abc6>] irq_exit+0x86/0x90
[  215.117191]  [<c010684a>] do_IRQ+0x9a/0x100
[  215.117203]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.117218]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.117234]  [<c01047f2>] common_interrupt+0x2e/0x34
[  215.117247]  [<c070007b>] ? tulip_init_one+0x5eb/0xda0
[  215.117262]  [<c0192e3a>] ? __mnt_is_readonly+0xa/0x20
[  215.117281]  [<c01959e7>] ? mnt_want_write+0x27/0x90
[  215.117299]  [<c0191a79>] file_update_time+0x39/0xd0
[  215.117322]  [<c018413a>] pipe_write+0x21a/0x450
[  215.117348]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.117364]  [<c017d55c>] do_sync_write+0xcc/0x110
[  215.117378]  [<c0138a80>] ? autoremove_wake_function+0x0/0x50
[  215.117401]  [<c01b1c9e>] ? dnotify_parent+0x6e/0x80
[  215.117423]  [<c0706d47>] ? _spin_unlock+0x27/0x50
[  215.117439]  [<c017dd99>] vfs_write+0x99/0x130
[  215.117451]  [<c017d490>] ? do_sync_write+0x0/0x110
[  215.117465]  [<c017e38d>] sys_write+0x3d/0x70
[  215.117478]  [<c0103d75>] sysenter_past_esp+0x6a/0xb1
[  215.117492]  =======================
[  215.117499] FIX skbuff_head_cache: Object at 0xccbf10a0 not freed
[  215.125990] =============================================================================
[  215.126042] BUG skbuff_head_cache: Invalid object pointer 0xccbe1820
[  215.126066] -----------------------------------------------------------------------------
[  215.126071] 
[  215.126095] INFO: Slab 0xc1199c20 used=5 fp=0xccbe1600 flags=0x40000083
[  215.126123] Pid: 3172, comm: dd Not tainted 2.6.25-03562-g3dc5063 #23
[  215.126135]  [<c0177b57>] slab_err+0x47/0x50
[  215.126172]  [<c0177bc7>] ? slab_pad_check+0x67/0xe0
[  215.126189]  [<c0177c92>] ? check_slab+0x52/0x80
[  215.126204]  [<c0179405>] __slab_free+0x1d5/0x2d0
[  215.126219]  [<c0179eb0>] kmem_cache_free+0x80/0xe0
[  215.126233]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.126258]  [<c05d91dc>] ? __kfree_skb+0x3c/0x90
[  215.126273]  [<c05d91dc>] __kfree_skb+0x3c/0x90
[  215.126285]  [<c05d9249>] kfree_skb+0x19/0x30
[  215.126298]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
[  215.126324]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.126359]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.126375]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.126389]  [<c012b075>] ? local_bh_enable_ip+0x85/0xf0
[  215.126420]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.126446]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.126461]  [<c0146721>] ? trace_hardirqs_on+0x81/0x150
[  215.126476]  [<c0680718>] ? ip6t_do_table+0x318/0x590
[  215.126490]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.126519]  [<c014424d>] ? put_lock_stats+0xd/0x30
[  215.126534]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.126550]  [<c0706615>] ? _spin_lock_nested+0x65/0x80
[  215.126580]  [<c0674e97>] ? tcp_v6_rcv+0x567/0x710
[  215.126594]  [<c0674f57>] tcp_v6_rcv+0x627/0x710
[  215.126608]  [<c06809c0>] ? ip6t_hook+0x0/0x30
[  215.126622]  [<c05f3c89>] ? nf_iterate+0x59/0x80
[  215.126654]  [<c0653ff2>] ip6_input_finish+0xc2/0x2a0
[  215.126672]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.126687]  [<c06541ef>] ip6_input+0x1f/0x60
[  215.126699]  [<c0653f30>] ? ip6_input_finish+0x0/0x2a0
[  215.126713]  [<c0654464>] ipv6_rcv+0x194/0x2e0
[  215.126725]  [<c0654290>] ? ip6_rcv_finish+0x0/0x40
[  215.126739]  [<c06542d0>] ? ipv6_rcv+0x0/0x2e0
[  215.126752]  [<c05de7f0>] netif_receive_skb+0x280/0x2f0
[  215.126767]  [<c05e1336>] process_backlog+0x76/0xd0
[  215.126783]  [<c05e0c90>] net_rx_action+0x120/0x1a0
[  215.126796]  [<c012ac92>] __do_softirq+0x62/0xc0
[  215.126810]  [<c010676a>] do_softirq+0x8a/0xd0
[  215.126826]  [<c0155f80>] ? handle_level_irq+0x0/0xe0
[  215.126842]  [<c012abc6>] irq_exit+0x86/0x90
[  215.126855]  [<c010684a>] do_IRQ+0x9a/0x100
[  215.126867]  [<c0109637>] ? native_sched_clock+0x67/0xb0
[  215.126883]  [<c01047f2>] common_interrupt+0x2e/0x34
[  215.126897]  [<c0140000>] ? sysfs_override_clocksource+0x70/0x100
[  215.126912]  [<c0706e67>] ? _spin_unlock_irqrestore+0x57/0x70
[  215.126929]  [<c011e5c6>] __wake_up_sync+0x46/0x60
[  215.126942]  [<c0184119>] pipe_write+0x1f9/0x450
[  215.126968]  [<c0146fe5>] ? __lock_acquire+0x395/0x1020
[  215.126983]  [<c017d55c>] do_sync_write+0xcc/0x110
[  215.126997]  [<c0138a80>] ? autoremove_wake_function+0x0/0x50
[  215.127021]  [<c01b1c9e>] ? dnotify_parent+0x6e/0x80
[  215.127044]  [<c0706d47>] ? _spin_unlock+0x27/0x50
[  215.127059]  [<c017dd99>] vfs_write+0x99/0x130
[  215.127071]  [<c017d490>] ? do_sync_write+0x0/0x110
[  215.127085]  [<c017e38d>] sys_write+0x3d/0x70
[  215.127098]  [<c0103d75>] sysenter_past_esp+0x6a/0xb1
[  215.127112]  =======================
[  215.127119] FIX skbuff_head_cache: Object at 0xccbe1820 not freed

Greetings, Eric

