From: Tommi Rantala <tt.rantala@gmail.com>
Subject: BUG ip_dst_cache (Not tainted): Poison overwritten
Date: Fri, 31 Jan 2014 22:11:51 +0200
Message-ID: <CA+ydwtrWCgi=v7v=8yjNMV37Aa4ua9zbqYM5_uUdQrLSQt+VEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Jones <davej@redhat.com>, trinity@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Hit this while fuzzing v3.13-9218-g0e47c96 with trinity in a qemu
virtual machine.

Tommi

[ 6329.061605] =============================================================================
[ 6329.062014] BUG ip_dst_cache (Not tainted): Poison overwritten
[ 6329.062014] -----------------------------------------------------------------------------
[ 6329.062014] Disabling lock debugging due to kernel taint
[ 6329.062014] INFO: 0xffff8800b4809940-0xffff8800b4809940. First byte
0x6a instead of 0x6b
[ 6329.062014] INFO: Allocated in dst_alloc+0x46/0x180 age=33 cpu=0 pid=6108
[ 6329.062014]  __slab_alloc+0x4f8/0x58c
[ 6329.062014]  kmem_cache_alloc+0x94/0x290
[ 6329.062014]  dst_alloc+0x46/0x180
[ 6329.062014]  rt_dst_alloc+0x47/0x50
[ 6329.062014]  __ip_route_output_key+0x882/0xa80
[ 6329.062014]  ip_route_output_flow+0x22/0x60
[ 6329.062014]  igmpv3_newpack+0xe2/0x210
[ 6329.062014]  add_grhead.isra.17+0x37/0xa0
[ 6329.062014]  add_grec+0x3b2/0x470
[ 6329.062014]  igmp_ifc_timer_expire+0x28e/0x400
[ 6329.062014]  call_timer_fn+0x146/0x320
[ 6329.062014]  run_timer_softirq+0x2d4/0x360
[ 6329.062014]  __do_softirq+0x217/0x4a0
[ 6329.062014]  irq_exit+0x45/0xb0
[ 6329.062014]  smp_apic_timer_interrupt+0x3f/0x50
[ 6329.062014]  apic_timer_interrupt+0x72/0x80
[ 6329.062014] INFO: Freed in dst_destroy+0x8a/0xe0 age=33 cpu=0 pid=6108
[ 6329.062014]  __slab_free+0x32/0x380
[ 6329.062014]  kmem_cache_free+0x186/0x2c0
[ 6329.062014]  dst_destroy+0x8a/0xe0
[ 6329.062014]  dst_release+0x53/0x70
[ 6329.062014]  ip_tunnel_xmit+0x50e/0xfb0
[ 6329.062014]  ipip_tunnel_xmit+0x41/0x60
[ 6329.062014]  dev_hard_start_xmit+0x3ed/0x950
[ 6329.062014]  __dev_queue_xmit+0x621/0x890
[ 6329.062014]  dev_queue_xmit+0xb/0x10
[ 6329.062014]  neigh_direct_output+0xc/0x10
[ 6329.062014]  ip_finish_output2+0x494/0x5d0
[ 6329.062014]  ip_finish_output+0x238/0x2d0
[ 6329.062014]  ip_output+0x9f/0x110
[ 6329.062014]  ip_local_out+0x6e/0xa0
[ 6329.062014]  igmpv3_sendpack+0x43/0x50
[ 6329.062014]  igmp_ifc_timer_expire+0x395/0x400
[ 6329.062014] INFO: Slab 0xffffea0002d20200 objects=14 used=14 fp=0x
        (null) flags=0x100000000004080
[ 6329.062014] INFO: Object 0xffff8800b48098c0 @offset=6336
fp=0xffff8800b4809680
[ 6329.062014] Bytes b4 ffff8800b48098b0: 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6329.062014] Object ffff8800b48098c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b48098d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b48098e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b48098f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809900: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809910: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809920: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809930: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809940: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809950: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809960: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6329.062014] Object ffff8800b4809970: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 6329.062014] Redzone ffff8800b4809980: bb bb bb bb bb bb bb bb
                   ........
[ 6329.062014] Padding ffff8800b4809ac0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6329.062014] Padding ffff8800b4809ad0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6329.062014] Padding ffff8800b4809ae0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6329.062014] Padding ffff8800b4809af0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6329.062014] CPU: 0 PID: 6108 Comm: trinity-main Tainted: G    B
   3.13.0+ #1
[ 6329.062014] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 6329.062014]  ffff8800b48098c0 ffff8800ab253b38 ffffffff82366c34
ffff8800baacd8c0
[ 6329.062014]  ffff8800ab253b68 ffffffff81262e41 ffff8800b4809941
ffff8800baacd8c0
[ 6329.062014]  000000000000006b ffff8800b48098c0 ffff8800ab253bb0
ffffffff81263284
[ 6329.062014] Call Trace:
[ 6329.062014]  [<ffffffff82366c34>] dump_stack+0x4d/0x66
[ 6329.062014]  [<ffffffff81262e41>] print_trailer+0x131/0x140
[ 6329.062014]  [<ffffffff81263284>] check_bytes_and_report+0xc4/0x120
[ 6329.062014]  [<ffffffff81263b5e>] check_object+0x11e/0x240
[ 6329.062014]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6329.062014]  [<ffffffff8236183c>] alloc_debug_processing+0x62/0x104
[ 6329.062014]  [<ffffffff8236256d>] __slab_alloc+0x4f8/0x58c
[ 6329.062014]  [<ffffffff8117a418>] ? sched_clock_cpu+0xb8/0xe0
[ 6329.062014]  [<ffffffff810ac027>] ? kvm_clock_read+0x27/0x40
[ 6329.062014]  [<ffffffff810787d9>] ? sched_clock+0x9/0x10
[ 6329.062014]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6329.062014]  [<ffffffff8117a418>] ? sched_clock_cpu+0xb8/0xe0
[ 6329.062014]  [<ffffffff8204e565>] ? fib_table_lookup+0x535/0x570
[ 6329.062014]  [<ffffffff8117a55a>] ? local_clock+0x1a/0x40
[ 6329.062014]  [<ffffffff8118fa38>] ? lock_release_holdtime+0x28/0x180
[ 6329.062014]  [<ffffffff81265b84>] kmem_cache_alloc+0x94/0x290
[ 6329.062014]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6329.062014]  [<ffffffff8204e57d>] ? fib_table_lookup+0x54d/0x570
[ 6329.062014]  [<ffffffff81f9d696>] dst_alloc+0x46/0x180
[ 6329.062014]  [<ffffffff8118f1b2>] ? __lock_is_held+0x52/0x80
[ 6329.062014]  [<ffffffff81ff58b7>] rt_dst_alloc+0x47/0x50
[ 6329.062014]  [<ffffffff81ff9a92>] __ip_route_output_key+0x882/0xa80
[ 6329.062014]  [<ffffffff81ff9210>] ? ip_route_input_noref+0x1060/0x1060
[ 6329.062014]  [<ffffffff81ffa002>] ip_route_output_flow+0x22/0x60
[ 6329.062014]  [<ffffffff8202a746>] ip4_datagram_release_cb+0x266/0x390
[ 6329.062014]  [<ffffffff8202a5a4>] ? ip4_datagram_release_cb+0xc4/0x390
[ 6329.062014]  [<ffffffff81f7de84>] release_sock+0x184/0x220
[ 6329.062014]  [<ffffffff81f7ed38>] sock_setsockopt+0xa58/0xa80
[ 6329.062014]  [<ffffffff814b5b06>] ? selinux_socket_setsockopt+0x46/0x60
[ 6329.062014]  [<ffffffff81f78e97>] SyS_setsockopt+0x77/0xe0
[ 6329.062014]  [<ffffffff82380e39>] system_call_fastpath+0x16/0x1b
[ 6329.062014] FIX ip_dst_cache: Restoring
0xffff8800b4809940-0xffff8800b4809940=0x6b
[ 6329.062014] FIX ip_dst_cache: Marking all objects used
[ 6342.045208] =============================================================================
[ 6342.046024] BUG ip_dst_cache (Tainted: G    B       ): Poison overwritten
[ 6342.046024] -----------------------------------------------------------------------------
[ 6342.046024] INFO: 0xffff8800541b9dc0-0xffff8800541b9dc0. First byte
0x6a instead of 0x6b
[ 6342.046024] INFO: Allocated in dst_alloc+0x46/0x180 age=12273 cpu=0 pid=8801
[ 6342.046024]  __slab_alloc+0x4f8/0x58c
[ 6342.046024]  kmem_cache_alloc+0x94/0x290
[ 6342.046024]  dst_alloc+0x46/0x180
[ 6342.046024]  rt_dst_alloc+0x47/0x50
[ 6342.046024]  __ip_route_output_key+0x882/0xa80
[ 6342.046024]  ip_route_output_flow+0x22/0x60
[ 6342.046024]  igmpv3_newpack+0xe2/0x210
[ 6342.046024]  add_grhead.isra.17+0x37/0xa0
[ 6342.046024]  add_grec+0x3b2/0x470
[ 6342.046024]  igmp_ifc_timer_expire+0x28e/0x400
[ 6342.046024]  call_timer_fn+0x146/0x320
[ 6342.046024]  run_timer_softirq+0x2d4/0x360
[ 6342.046024]  __do_softirq+0x217/0x4a0
[ 6342.046024]  irq_exit+0x45/0xb0
[ 6342.046024]  smp_apic_timer_interrupt+0x3f/0x50
[ 6342.046024]  apic_timer_interrupt+0x72/0x80
[ 6342.046024] INFO: Freed in dst_destroy+0x8a/0xe0 age=12273 cpu=0 pid=8801
[ 6342.046024]  __slab_free+0x32/0x380
[ 6342.046024]  kmem_cache_free+0x186/0x2c0
[ 6342.046024]  dst_destroy+0x8a/0xe0
[ 6342.046024]  dst_release+0x53/0x70
[ 6342.046024]  ip_tunnel_xmit+0x50e/0xfb0
[ 6342.046024]  ipip_tunnel_xmit+0x41/0x60
[ 6342.046024]  dev_hard_start_xmit+0x3ed/0x950
[ 6342.046024]  __dev_queue_xmit+0x621/0x890
[ 6342.046024]  dev_queue_xmit+0xb/0x10
[ 6342.046024]  neigh_direct_output+0xc/0x10
[ 6342.046024]  ip_finish_output2+0x494/0x5d0
[ 6342.046024]  ip_finish_output+0x238/0x2d0
[ 6342.046024]  ip_output+0x9f/0x110
[ 6342.046024]  ip_local_out+0x6e/0xa0
[ 6342.046024]  igmpv3_sendpack+0x43/0x50
[ 6342.046024]  igmp_ifc_timer_expire+0x395/0x400
[ 6342.046024] INFO: Slab 0xffffea0001506e00 objects=14 used=14 fp=0x
        (null) flags=0x100000000004080
[ 6342.046024] INFO: Object 0xffff8800541b9d40 @offset=7488
fp=0xffff8800541b8240
[ 6342.046024] Bytes b4 ffff8800541b9d30: 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6342.046024] Object ffff8800541b9d40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9d50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9d60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9d70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9d80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9d90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9da0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9db0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9dc0: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9dd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9de0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6342.046024] Object ffff8800541b9df0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 6342.046024] Redzone ffff8800541b9e00: bb bb bb bb bb bb bb bb
                   ........
[ 6342.046024] Padding ffff8800541b9f40: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6342.046024] Padding ffff8800541b9f50: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6342.046024] Padding ffff8800541b9f60: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6342.046024] Padding ffff8800541b9f70: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6342.046024] CPU: 0 PID: 2715 Comm: dhcpcd Tainted: G    B        3.13.0+ #1
[ 6342.046024] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 6342.046024]  ffff8800541b9d40 ffff8800b66f78a8 ffffffff82366c34
ffff8800baacd8c0
[ 6342.046024]  ffff8800b66f78d8 ffffffff81262e41 ffff8800541b9dc1
ffff8800baacd8c0
[ 6342.046024]  000000000000006b ffff8800541b9d40 ffff8800b66f7920
ffffffff81263284
[ 6342.046024] Call Trace:
[ 6342.046024]  [<ffffffff82366c34>] dump_stack+0x4d/0x66
[ 6342.046024]  [<ffffffff81262e41>] print_trailer+0x131/0x140
[ 6342.046024]  [<ffffffff81263284>] check_bytes_and_report+0xc4/0x120
[ 6342.046024]  [<ffffffff81263b5e>] check_object+0x11e/0x240
[ 6342.046024]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6342.046024]  [<ffffffff8236183c>] alloc_debug_processing+0x62/0x104
[ 6342.046024]  [<ffffffff8236256d>] __slab_alloc+0x4f8/0x58c
[ 6342.046024]  [<ffffffff81f80c28>] ? __alloc_skb+0x88/0x250
[ 6342.046024]  [<ffffffff8107efa6>] ? save_stack_trace+0x26/0x50
[ 6342.046024]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6342.046024]  [<ffffffff811919f6>] ? trace_hardirqs_on_caller+0x16/0x220
[ 6342.046024]  [<ffffffff81191c0d>] ? trace_hardirqs_on+0xd/0x10
[ 6342.046024]  [<ffffffff81265b84>] kmem_cache_alloc+0x94/0x290
[ 6342.046024]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6342.046024]  [<ffffffff81f9d696>] dst_alloc+0x46/0x180
[ 6342.046024]  [<ffffffff81ff58b7>] rt_dst_alloc+0x47/0x50
[ 6342.046024]  [<ffffffff81ff9a92>] __ip_route_output_key+0x882/0xa80
[ 6342.046024]  [<ffffffff81ff9210>] ? ip_route_input_noref+0x1060/0x1060
[ 6342.046024]  [<ffffffff81f80c28>] ? __alloc_skb+0x88/0x250
[ 6342.046024]  [<ffffffff81ffa002>] ip_route_output_flow+0x22/0x60
[ 6342.046024]  [<ffffffff82060ebf>] vti_tunnel_xmit+0x9f/0x450
[ 6342.046024]  [<ffffffff81f93dbd>] dev_hard_start_xmit+0x3ed/0x950
[ 6342.046024]  [<ffffffff81f94320>] ? dev_hard_start_xmit+0x950/0x950
[ 6342.046024]  [<ffffffff81f94941>] __dev_queue_xmit+0x621/0x890
[ 6342.046024]  [<ffffffff81f94320>] ? dev_hard_start_xmit+0x950/0x950
[ 6342.046024]  [<ffffffff81f94bbb>] dev_queue_xmit+0xb/0x10
[ 6342.046024]  [<ffffffff820f5c89>] packet_sendmsg+0x559/0x5e0
[ 6342.046024]  [<ffffffff81f77987>] sock_sendmsg+0x97/0xd0
[ 6342.046024]  [<ffffffff8123ff45>] ? might_fault+0x55/0xb0
[ 6342.046024]  [<ffffffff8123ff8e>] ? might_fault+0x9e/0xb0
[ 6342.046024]  [<ffffffff8123ff45>] ? might_fault+0x55/0xb0
[ 6342.046024]  [<ffffffff81f77e6c>] SYSC_sendto+0x11c/0x160
[ 6342.046024]  [<ffffffff81f78dc9>] SyS_sendto+0x9/0x10
[ 6342.046024]  [<ffffffff82380e39>] system_call_fastpath+0x16/0x1b
[ 6342.046024] FIX ip_dst_cache: Restoring
0xffff8800541b9dc0-0xffff8800541b9dc0=0x6b
[ 6342.046024] FIX ip_dst_cache: Marking all objects used
[ 6344.988076] =============================================================================
[ 6344.989020] BUG ip_dst_cache (Tainted: G    B       ): Poison overwritten
[ 6344.989020] -----------------------------------------------------------------------------
[ 6344.989020] INFO: 0xffff8800a3bc8080-0xffff8800a3bc8080. First byte
0x6a instead of 0x6b
[ 6344.989020] INFO: Allocated in dst_alloc+0x46/0x180 age=705 cpu=0 pid=6108
[ 6344.989020]  __slab_alloc+0x4f8/0x58c
[ 6344.989020]  kmem_cache_alloc+0x94/0x290
[ 6344.989020]  dst_alloc+0x46/0x180
[ 6344.989020]  rt_dst_alloc+0x47/0x50
[ 6344.989020]  __ip_route_output_key+0x882/0xa80
[ 6344.989020]  ip_route_output_flow+0x22/0x60
[ 6344.989020]  igmpv3_newpack+0xe2/0x210
[ 6344.989020]  add_grhead.isra.17+0x37/0xa0
[ 6344.989020]  add_grec+0x3b2/0x470
[ 6344.989020]  igmp_ifc_timer_expire+0x11a/0x400
[ 6344.989020]  call_timer_fn+0x146/0x320
[ 6344.989020]  run_timer_softirq+0x2d4/0x360
[ 6344.989020]  __do_softirq+0x217/0x4a0
[ 6344.989020]  irq_exit+0x45/0xb0
[ 6344.989020]  smp_apic_timer_interrupt+0x3f/0x50
[ 6344.989020]  apic_timer_interrupt+0x72/0x80
[ 6344.989020] INFO: Freed in dst_destroy+0x8a/0xe0 age=705 cpu=0 pid=6108
[ 6344.989020]  __slab_free+0x32/0x380
[ 6344.989020]  kmem_cache_free+0x186/0x2c0
[ 6344.989020]  dst_destroy+0x8a/0xe0
[ 6344.989020]  dst_release+0x53/0x70
[ 6344.989020]  ip_tunnel_xmit+0x50e/0xfb0
[ 6344.989020]  ipip_tunnel_xmit+0x41/0x60
[ 6344.989020]  dev_hard_start_xmit+0x3ed/0x950
[ 6344.989020]  __dev_queue_xmit+0x621/0x890
[ 6344.989020]  dev_queue_xmit+0xb/0x10
[ 6344.989020]  neigh_direct_output+0xc/0x10
[ 6344.989020]  ip_finish_output2+0x494/0x5d0
[ 6344.989020]  ip_finish_output+0x238/0x2d0
[ 6344.989020]  ip_output+0x9f/0x110
[ 6344.989020]  ip_local_out+0x6e/0xa0
[ 6344.989020]  igmpv3_sendpack+0x43/0x50
[ 6344.989020]  igmp_ifc_timer_expire+0x395/0x400
[ 6344.989020] INFO: Slab 0xffffea00028ef200 objects=14 used=14 fp=0x
        (null) flags=0x100000000004080
[ 6344.989020] INFO: Object 0xffff8800a3bc8000 @offset=0 fp=0xffff8800a3bc8240
[ 6344.989020] Object ffff8800a3bc8000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8080: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc8090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc80a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6344.989020] Object ffff8800a3bc80b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 6344.989020] Redzone ffff8800a3bc80c0: bb bb bb bb bb bb bb bb
                   ........
[ 6344.989020] Padding ffff8800a3bc8200: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6344.989020] Padding ffff8800a3bc8210: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6344.989020] Padding ffff8800a3bc8220: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6344.989020] Padding ffff8800a3bc8230: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6344.989020] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B        3.13.0+ #1
[ 6344.989020] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 6344.989020]  ffff8800a3bc8000 ffff8800bf6039b8 ffffffff82366c34
ffff8800baacd8c0
[ 6344.989020]  ffff8800bf6039e8 ffffffff81262e41 ffff8800a3bc8081
ffff8800baacd8c0
[ 6344.989020]  000000000000006b ffff8800a3bc8000 ffff8800bf603a30
ffffffff81263284
[ 6344.989020] Call Trace:
[ 6344.989020]  <IRQ>  [<ffffffff82366c34>] dump_stack+0x4d/0x66
[ 6344.989020]  [<ffffffff81262e41>] print_trailer+0x131/0x140
[ 6344.989020]  [<ffffffff81263284>] check_bytes_and_report+0xc4/0x120
[ 6344.989020]  [<ffffffff81263b5e>] check_object+0x11e/0x240
[ 6344.989020]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6344.989020]  [<ffffffff8236183c>] alloc_debug_processing+0x62/0x104
[ 6344.989020]  [<ffffffff8236256d>] __slab_alloc+0x4f8/0x58c
[ 6344.989020]  [<ffffffff811919f6>] ? trace_hardirqs_on_caller+0x16/0x220
[ 6344.989020]  [<ffffffff81191c0d>] ? trace_hardirqs_on+0xd/0x10
[ 6344.989020]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6344.989020]  [<ffffffff81191c0d>] ? trace_hardirqs_on+0xd/0x10
[ 6344.989020]  [<ffffffff81f80c28>] ? __alloc_skb+0x88/0x250
[ 6344.989020]  [<ffffffff81265b84>] kmem_cache_alloc+0x94/0x290
[ 6344.989020]  [<ffffffff8203b150>] ? devinet_ioctl+0x740/0x740
[ 6344.989020]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6344.989020]  [<ffffffff81f9d696>] dst_alloc+0x46/0x180
[ 6344.989020]  [<ffffffff81ff58b7>] rt_dst_alloc+0x47/0x50
[ 6344.989020]  [<ffffffff81ff9a92>] __ip_route_output_key+0x882/0xa80
[ 6344.989020]  [<ffffffff81ff9210>] ? ip_route_input_noref+0x1060/0x1060
[ 6344.989020]  [<ffffffff81ffa002>] ip_route_output_flow+0x22/0x60
[ 6344.989020]  [<ffffffff8203fc62>] igmpv3_newpack+0xe2/0x210
[ 6344.989020]  [<ffffffff8203fdc7>] add_grhead.isra.17+0x37/0xa0
[ 6344.989020]  [<ffffffff820401e2>] add_grec+0x3b2/0x470
[ 6344.989020]  [<ffffffff82041850>] ? igmp_ifc_timer_expire+0x90/0x400
[ 6344.989020]  [<ffffffff820418da>] igmp_ifc_timer_expire+0x11a/0x400
[ 6344.989020]  [<ffffffff820417c0>] ? igmp_mc_get_next.isra.15+0x250/0x250
[ 6344.989020]  [<ffffffff820417c0>] ? igmp_mc_get_next.isra.15+0x250/0x250
[ 6344.989020]  [<ffffffff81149596>] call_timer_fn+0x146/0x320
[ 6344.989020]  [<ffffffff81149450>] ? ftrace_raw_event_timer_start+0x180/0x180
[ 6344.989020]  [<ffffffff820417c0>] ? igmp_mc_get_next.isra.15+0x250/0x250
[ 6344.989020]  [<ffffffff81149a44>] run_timer_softirq+0x2d4/0x360
[ 6344.989020]  [<ffffffff8113fb17>] __do_softirq+0x217/0x4a0
[ 6344.989020]  [<ffffffff81140025>] irq_exit+0x45/0xb0
[ 6344.989020]  [<ffffffff810a31bf>] smp_apic_timer_interrupt+0x3f/0x50
[ 6344.989020]  [<ffffffff82381ab2>] apic_timer_interrupt+0x72/0x80
[ 6344.989020]  <EOI>  [<ffffffff81079a8d>] ? default_idle+0xed/0x270
[ 6344.989020]  [<ffffffff81191c0d>] ? trace_hardirqs_on+0xd/0x10
[ 6344.989020]  [<ffffffff810ac416>] ? native_safe_halt+0x6/0x10
[ 6344.989020]  [<ffffffff81079a92>] default_idle+0xf2/0x270
[ 6344.989020]  [<ffffffff8107a3d3>] arch_cpu_idle+0x13/0x30
[ 6344.989020]  [<ffffffff811a0457>] cpu_startup_entry+0x2e7/0x400
[ 6344.989020]  [<ffffffff82357ad8>] rest_init+0x138/0x140
[ 6344.989020]  [<ffffffff823579a0>] ? csum_partial_copy_generic+0x170/0x170
[ 6344.989020]  [<ffffffff82febf3d>] start_kernel+0x40b/0x418
[ 6344.989020]  [<ffffffff82feb8b0>] ? repair_env_string+0x5e/0x5e
[ 6344.989020]  [<ffffffff82feb117>] ? early_idt_handlers+0x117/0x120
[ 6344.989020]  [<ffffffff82feb5e0>] x86_64_start_reservations+0x2a/0x2c
[ 6344.989020]  [<ffffffff82feb728>] x86_64_start_kernel+0x146/0x155
[ 6344.989020] FIX ip_dst_cache: Restoring
0xffff8800a3bc8080-0xffff8800a3bc8080=0x6b
[ 6344.989020] FIX ip_dst_cache: Marking all objects used
[ 6346.340084] =============================================================================
[ 6346.341017] BUG ip_dst_cache (Tainted: G    B       ): Poison overwritten
[ 6346.341017] -----------------------------------------------------------------------------
[ 6346.341017] INFO: 0xffff8800ab252080-0xffff8800ab252080. First byte
0x6a instead of 0x6b
[ 6346.341017] INFO: Allocated in dst_alloc+0x46/0x180 age=1352 cpu=0 pid=0
[ 6346.341017]  __slab_alloc+0x4f8/0x58c
[ 6346.341017]  kmem_cache_alloc+0x94/0x290
[ 6346.341017]  dst_alloc+0x46/0x180
[ 6346.341017]  rt_dst_alloc+0x47/0x50
[ 6346.341017]  __ip_route_output_key+0x882/0xa80
[ 6346.341017]  ip_route_output_flow+0x22/0x60
[ 6346.341017]  igmpv3_newpack+0xe2/0x210
[ 6346.341017]  add_grhead.isra.17+0x37/0xa0
[ 6346.341017]  add_grec+0x3b2/0x470
[ 6346.341017]  igmp_ifc_timer_expire+0x11a/0x400
[ 6346.341017]  call_timer_fn+0x146/0x320
[ 6346.341017]  run_timer_softirq+0x2d4/0x360
[ 6346.341017]  __do_softirq+0x217/0x4a0
[ 6346.341017]  irq_exit+0x45/0xb0
[ 6346.341017]  smp_apic_timer_interrupt+0x3f/0x50
[ 6346.341017]  apic_timer_interrupt+0x72/0x80
[ 6346.341017] INFO: Freed in dst_destroy+0x8a/0xe0 age=1184 cpu=0 pid=0
[ 6346.341017]  __slab_free+0x32/0x380
[ 6346.341017]  kmem_cache_free+0x186/0x2c0
[ 6346.341017]  dst_destroy+0x8a/0xe0
[ 6346.341017]  dst_release+0x53/0x70
[ 6346.341017]  ip_tunnel_xmit+0x50e/0xfb0
[ 6346.341017]  ipip_tunnel_xmit+0x41/0x60
[ 6346.341017]  dev_hard_start_xmit+0x3ed/0x950
[ 6346.341017]  __dev_queue_xmit+0x621/0x890
[ 6346.341017]  dev_queue_xmit+0xb/0x10
[ 6346.341017]  neigh_direct_output+0xc/0x10
[ 6346.341017]  ip_finish_output2+0x494/0x5d0
[ 6346.341017]  ip_finish_output+0x238/0x2d0
[ 6346.341017]  ip_output+0x9f/0x110
[ 6346.341017]  ip_local_out+0x6e/0xa0
[ 6346.341017]  igmpv3_sendpack+0x43/0x50
[ 6346.341017]  igmp_ifc_timer_expire+0x395/0x400
[ 6346.341017] INFO: Slab 0xffffea0002ac9480 objects=14 used=14 fp=0x
        (null) flags=0x100000000004080
[ 6346.341017] INFO: Object 0xffff8800ab252000 @offset=0 fp=0xffff8800ab253d40
[ 6346.341017] Object ffff8800ab252000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252080: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab252090: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab2520a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[ 6346.341017] Object ffff8800ab2520b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[ 6346.341017] Redzone ffff8800ab2520c0: bb bb bb bb bb bb bb bb
                   ........
[ 6346.341017] Padding ffff8800ab252200: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6346.341017] Padding ffff8800ab252210: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6346.341017] Padding ffff8800ab252220: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6346.341017] Padding ffff8800ab252230: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[ 6346.341017] CPU: 0 PID: 2715 Comm: dhcpcd Tainted: G    B        3.13.0+ #1
[ 6346.341017] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 6346.341017]  ffff8800ab252000 ffff8800b66f77e8 ffffffff82366c34
ffff8800baacd8c0
[ 6346.341017]  ffff8800b66f7818 ffffffff81262e41 ffff8800ab252081
ffff8800baacd8c0
[ 6346.341017]  000000000000006b ffff8800ab252000 ffff8800b66f7860
ffffffff81263284
[ 6346.341017] Call Trace:
[ 6346.341017]  [<ffffffff82366c34>] dump_stack+0x4d/0x66
[ 6346.341017]  [<ffffffff81262e41>] print_trailer+0x131/0x140
[ 6346.341017]  [<ffffffff81263284>] check_bytes_and_report+0xc4/0x120
[ 6346.341017]  [<ffffffff81263b5e>] check_object+0x11e/0x240
[ 6346.341017]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6346.341017]  [<ffffffff8236183c>] alloc_debug_processing+0x62/0x104
[ 6346.341017]  [<ffffffff8236256d>] __slab_alloc+0x4f8/0x58c
[ 6346.341017]  [<ffffffff81264df9>] ? deactivate_slab+0x279/0x550
[ 6346.341017]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6346.341017]  [<ffffffff8204d064>] ? check_leaf.isra.6+0x84/0x2d0
[ 6346.341017]  [<ffffffff81265b84>] kmem_cache_alloc+0x94/0x290
[ 6346.341017]  [<ffffffff81f9d696>] ? dst_alloc+0x46/0x180
[ 6346.341017]  [<ffffffff8204e57d>] ? fib_table_lookup+0x54d/0x570
[ 6346.341017]  [<ffffffff81f9d696>] dst_alloc+0x46/0x180
[ 6346.341017]  [<ffffffff81ff58b7>] rt_dst_alloc+0x47/0x50
[ 6346.341017]  [<ffffffff81ff9a92>] __ip_route_output_key+0x882/0xa80
[ 6346.341017]  [<ffffffff81ff9210>] ? ip_route_input_noref+0x1060/0x1060
[ 6346.341017]  [<ffffffff81ffa002>] ip_route_output_flow+0x22/0x60
[ 6346.341017]  [<ffffffff82053ae8>] ip_tunnel_xmit+0x4b8/0xfb0
[ 6346.341017]  [<ffffffff82053932>] ? ip_tunnel_xmit+0x302/0xfb0
[ 6346.341017]  [<ffffffff8205eb33>] __gre_xmit+0x73/0x90
[ 6346.341017]  [<ffffffff8205f042>] ipgre_xmit+0x172/0x1a0
[ 6346.341017]  [<ffffffff81f93dbd>] dev_hard_start_xmit+0x3ed/0x950
[ 6346.341017]  [<ffffffff81f94320>] ? dev_hard_start_xmit+0x950/0x950
[ 6346.341017]  [<ffffffff8205eda0>] ? gre_tap_xmit+0xd0/0xd0
[ 6346.341017]  [<ffffffff81f94941>] __dev_queue_xmit+0x621/0x890
[ 6346.341017]  [<ffffffff81f94320>] ? dev_hard_start_xmit+0x950/0x950
[ 6346.341017]  [<ffffffff8205eda0>] ? gre_tap_xmit+0xd0/0xd0
[ 6346.341017]  [<ffffffff81f94bbb>] dev_queue_xmit+0xb/0x10
[ 6346.341017]  [<ffffffff820f5c89>] packet_sendmsg+0x559/0x5e0
[ 6346.341017]  [<ffffffff81f77987>] sock_sendmsg+0x97/0xd0
[ 6346.341017]  [<ffffffff8123ff45>] ? might_fault+0x55/0xb0
[ 6346.341017]  [<ffffffff8123ff8e>] ? might_fault+0x9e/0xb0
[ 6346.341017]  [<ffffffff8123ff45>] ? might_fault+0x55/0xb0
[ 6346.341017]  [<ffffffff81f77e6c>] SYSC_sendto+0x11c/0x160
[ 6346.341017]  [<ffffffff81f78dc9>] SyS_sendto+0x9/0x10
[ 6346.341017]  [<ffffffff82380e39>] system_call_fastpath+0x16/0x1b
[ 6346.341017] FIX ip_dst_cache: Restoring
0xffff8800ab252080-0xffff8800ab252080=0x6b
[ 6346.341017] FIX ip_dst_cache: Marking all objects used
[19618.459429] sock: sock_set_timeout: `trinity-main' (pid 30849)
tries to set negative timeout
