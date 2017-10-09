From: Eric Dumazet <edumazet@google.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000]
Date: Sun, 8 Oct 2017 20:47:10 -0700
Message-ID: <CANn89i+4iYzw03zKgPCcYNKfonM+HPwiEqQZ97n2vCWUt+Y9Qg@mail.gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com> <20171008204304.58ec8e5e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:49867 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753740AbdJIDrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 23:47:12 -0400
Received: by mail-vk0-f46.google.com with SMTP id h191so12097506vke.6
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 20:47:12 -0700 (PDT)
In-Reply-To: <20171008204304.58ec8e5e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 8, 2017 at 8:43 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> Hi!
>
> This appeared in net-next over the weekend - looks likely related to
> this set...
>
> [  164.456668] BUG: using smp_processor_id() in preemptible [00000000] code: sshd/1255
> [  164.472259] caller is ip6_pol_route+0xe88/0x4a80
> [  164.477571] CPU: 10 PID: 1255 Comm: sshd Not tainted 4.14.0-rc3-debug-00960-g58e545033ed7 #312
> [  164.487350] Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.3.4 11/08/2016
> [  164.495884] Call Trace:
> [  164.498771]  dump_stack+0xb3/0x140
> [  164.502720]  ? _atomic_dec_and_lock+0x2b0/0x2b0
> [  164.507909]  ? __lock_is_held+0xcf/0x1a0
> [  164.512492]  check_preemption_disabled+0x1a0/0x1d0
> [  164.517974]  ip6_pol_route+0xe88/0x4a80
> [  164.522402]  ? ip6_rt_update_pmtu+0xc0/0xc0
> [  164.527205]  ? unwind_get_return_address+0x5f/0xc0
> [  164.532685]  ? print_usage_bug+0x5a0/0x5a0
> [  164.537399]  ? lock_downgrade+0x740/0x740
> [  164.542000]  ? deref_stack_reg+0x75/0x230
> [  164.546605]  ? __read_once_size_nocheck.constprop.3+0x50/0x50
> [  164.553158]  ? print_usage_bug+0x5a0/0x5a0
> [  164.557859]  ? bpf_prog_alloc+0x330/0x330
> [  164.562467]  ? lock_downgrade+0x740/0x740
> [  164.567076]  ? __mod_tree_remove+0x40/0x40
> [  164.571774]  ? deref_stack_reg+0x75/0x230
> [  164.576414]  ? __read_once_size_nocheck.constprop.3+0x50/0x50
> [  164.582964]  ? deref_stack_reg+0x230/0x230
> [  164.587676]  ? __free_insn_slot+0x970/0x970
> [  164.592507]  ? print_usage_bug+0x5a0/0x5a0
> [  164.597203]  ? deref_stack_reg+0x75/0x230
> [  164.601804]  ? __read_once_size_nocheck.constprop.3+0x50/0x50
> [  164.608412]  ? show_rcu_gp_kthreads+0x160/0x160
> [  164.613601]  ? is_bpf_text_address+0xa4/0x130
> [  164.618590]  ? bpf_prog_alloc+0x330/0x330
> [  164.623194]  ? kernel_text_address+0xec/0x120
> [  164.628200]  ? cyc2ns_read_end+0x20/0x20
> [  164.632705]  ? __mod_tree_remove+0x40/0x40
> [  164.637403]  ? deref_stack_reg+0x75/0x230
> [  164.642006]  ? __read_once_size_nocheck.constprop.3+0x50/0x50
> [  164.648552]  ? deref_stack_reg+0x75/0x230
> [  164.653165]  ? sched_clock_cpu+0x18/0x290
> [  164.657768]  ? lock_downgrade+0x740/0x740
> [  164.662383]  ? bpf_prog_alloc+0x330/0x330
> [  164.666978]  ? lock_downgrade+0x740/0x740
> [  164.671581]  ? debug_check_no_locks_freed+0x2f0/0x2f0
> [  164.677425]  ? deref_stack_reg+0x75/0x230
> [  164.677432]  ? __read_once_size_nocheck.constprop.3+0x50/0x50
> [  164.677438]  ? deref_stack_reg+0x230/0x230
> [  164.677445]  ? deref_stack_reg+0x230/0x230
> [  164.677458]  ? rcu_read_lock_held+0xc0/0xc0
> [  164.677466]  ? __free_insn_slot+0x970/0x970
> [  164.677476]  ? rcu_is_watching+0x59/0x1f0
> [  164.677483]  ? show_rcu_gp_kthreads+0x160/0x160
> [  164.677496]  ? is_bpf_text_address+0xa4/0x130
> [  164.677504]  ? kernel_text_address+0xec/0x120
> [  164.677509]  ? __kernel_text_address+0xe/0x30
> [  164.677516]  ? __kernel_text_address+0xe/0x30
> [  164.677523]  ? unwind_get_return_address+0x5f/0xc0
> [  164.677532]  ? __save_stack_trace+0x83/0x120
> [  164.677549]  ? __lock_acquire+0x1fcf/0x4440
> [  164.677557]  ? save_trace+0x350/0x350
> [  164.677566]  ? cyc2ns_read_end+0x20/0x20
> [  164.677580]  ? debug_check_no_locks_freed+0x2f0/0x2f0
> [  164.677589]  ? ip6_pol_route_input+0x90/0x90
> [  164.677595]  fib6_rule_lookup+0x10a/0x750
> [  164.677604]  ? fib6_rules_seq_read+0x10/0x10
> [  164.677623]  ? lock_downgrade+0x740/0x740
> [  164.677631]  ? ip6_route_output_flags+0x1ff/0x310
> [  164.677642]  ip6_dst_lookup_tail+0x4ce/0xd50
> [  164.677671]  ip6_dst_lookup_flow+0xce/0x2a0
> [  164.677679]  ? ip6_dst_lookup+0x90/0x90
> [  164.677684]  ? __lock_is_held+0xcf/0x1a0
> [  164.677690]  ? show_rcu_gp_kthreads+0x160/0x160
> [  164.677704]  ip6_datagram_dst_update+0x728/0x1b00
> [  164.677711]  ? cyc2ns_read_end+0x20/0x20
> [  164.677721]  ? ip6_datagram_send_ctl+0x1400/0x1400
> [  164.677733]  ? print_usage_bug+0x5a0/0x5a0
> [  164.677741]  ? sched_clock_cpu+0x18/0x290
> [  164.677759]  ? lock_downgrade+0x740/0x740
> [  164.677765]  ? get_lock_stats+0x18/0x160
> [  164.677788]  ? __ip6_datagram_connect+0x51b/0x1410
> [  164.677793]  __ip6_datagram_connect+0x51b/0x1410
> [  164.677803]  ? ip6_datagram_release_cb+0x5f0/0x5f0
> [  164.677809]  ? mark_held_locks+0xce/0x170
> [  164.677817]  ? __local_bh_enable_ip+0x5f/0xa0
> [  164.677830]  ip6_datagram_connect+0x27/0x40
> [  164.677839]  SYSC_connect+0x1e8/0x4a0
> [  164.677847]  ? SYSC_bind+0x3e0/0x3e0
> [  164.677856]  ? get_unused_fd_flags+0x133/0x210
> [  164.677863]  ? trace_raw_output_sys_exit+0x110/0x110
> [  164.677874]  ? __close_fd+0x242/0x400
> [  164.677883]  ? sock_map_fd+0x3d/0x60
> [  164.677893]  ? entry_SYSCALL_64_fastpath+0x5/0xb1
> [  164.677901]  ? trace_hardirqs_on_caller+0x3cb/0x680
> [  164.677908]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> [  164.677919]  entry_SYSCALL_64_fastpath+0x1c/0xb1
> [  164.677926] RIP: 0033:0x7f44264eb160
> [  164.677931] RSP: 002b:00007ffe6e705f88 EFLAGS: 00000246 ORIG_RAX: 000000000000002a
> [  164.677939] RAX: ffffffffffffffda RBX: 0000000000000046 RCX: 00007f44264eb160
> [  164.677943] RDX: 000000000000001c RSI: 000055de0fedc2b0 RDI: 0000000000000003
> [  164.677948] RBP: 00007ffe6e7060e0 R08: 0100007fffff0000 R09: 0000000200001600
> [  164.677952] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffe6e706090
> [  164.677956] R13: 00007ffe6e7060a0 R14: 0000000000000003 R15: 00007ffe6e705f40


Hi Jakub

This was discussed/reported earlier today by Ido.

https://patchwork.ozlabs.org/patch/823011/

We will submit an official fix shortly.

Thanks.
