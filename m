From: Joe Smith <codesoldier1@gmail.com>
Subject: Help with debugging CPU stall
Date: Wed, 9 Aug 2017 15:41:38 -0700
Message-ID: <CABGNecx7wxm7XAwdv-4F3LEkRebV=gDf0AK-mnJF-0Dn7PJtUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33383 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752181AbdHIWlj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 18:41:39 -0400
Received: by mail-io0-f179.google.com with SMTP id j32so3671313iod.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 15:41:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am debugging a system where rcu_sched detects cpu stall. The system
is running a test which runs fine if IPSec is not used. With IPSec it
stalls. I have tried reducing the value of netdev_budget to 100 but
that seems to have no impact. I have included two stack traces below.


How do I figure out where the system is looping/stuck.


Thanks for the help.

Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410509]
[<ffffffff81510da9>] ? do_IRQ+0x69/0xe0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410513]
[<ffffffff81507053>] ? common_interrupt+0x13/0x13
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410520]
[<ffffffff8105822c>] ? sched_slice+0x4c/0x90
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410524]
[<ffffffff810dd8a2>] print_cpu_stall+0x42/0xa0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410528]
[<ffffffff810ddb2a>] check_cpu_stall+0xca/0xe0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410533]
[<ffffffff810ddb70>] __rcu_pending+0x30/0x140
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410537]
[<ffffffff810ddcb7>] rcu_pending+0x37/0x90
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410541]
[<ffffffff810dde95>] rcu_check_callbacks+0x85/0xa0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410546]
[<ffffffff8107e7b6>] update_process_times+0x46/0x90
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410553]
[<ffffffff810a31d6>] tick_sched_timer+0x66/0xd0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410557]
[<ffffffff810a3170>] ? tick_clock_notify+0x60/0x60
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410563]
[<ffffffff81095c63>] __run_hrtimer+0x83/0x1e0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410566]
[<ffffffff81095f76>] hrtimer_interrupt+0xe6/0x240
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410573]
[<ffffffff81033e6b>] local_apic_timer_interrupt+0x3b/0x70
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410578]
[<ffffffff81510e65>] smp_apic_timer_interrupt+0x45/0x5a
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410582]
[<ffffffff8150fcf3>] apic_timer_interrupt+0x13/0x20
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410586]
[<ffffffff81223a90>] shash_finup_unaligned+0x30/0x40
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410592]
[<ffffffffa05a163a>] ? dec128+0x742/0x818 [aes_x86_64]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410597]
[<ffffffffa05a1722>] ? aes_decrypt+0x12/0x30 [aes_x86_64]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410602]
[<ffffffffa05d5372>] ? crypto_cbc_decrypt_inplace+0xc2/0x120 [cbc]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410607]
[<ffffffffa05a1710>] ? dec128+0x818/0x818 [aes_x86_64]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410612]
[<ffffffffa05d553d>] ? crypto_cbc_decrypt+0x7d/0x90 [cbc]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410617]
[<ffffffff8122195d>] ? async_decrypt+0x3d/0x40
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410621]
[<ffffffffa0643e08>] ? crypto_authenc_decrypt+0xa8/0xb0 [authenc]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410626]
[<ffffffffa0578fc8>] ? esp_input+0x1e8/0x350 [esp4]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410630]
[<ffffffff814c3fe9>] ? xfrm_state_lookup+0x69/0x90
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410634]
[<ffffffff814c7c31>] ? xfrm_input+0x691/0x6e0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410639]
[<ffffffff814bb950>] ? xfrm4_rcv_encap+0x20/0x30
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410643]
[<ffffffff814bb9a4>] ? xfrm4_rcv+0x24/0x30
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410647]
[<ffffffff8146f399>] ? ip_local_deliver_finish+0x129/0x280
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410650]
[<ffffffff8146eef0>] ? ip_local_deliver+0x40/0xa0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410654]
[<ffffffff8146f669>] ? ip_rcv_finish+0x179/0x380
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410658]
[<ffffffff8146f172>] ? ip_rcv+0x222/0x320
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410662]
[<ffffffff814393ab>] ? __netif_receive_skb+0x25b/0x500
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410667]
[<ffffffff8143a58d>] ? netif_receive_skb+0x7d/0x90
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410671]
[<ffffffff8126aa7d>] ? swiotlb_sync_single+0x2d/0x70
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410675]
[<ffffffff8143a678>] ? napi_skb_finish+0x48/0x60
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410679]
[<ffffffff8143ab1b>] ? napi_gro_receive+0xfb/0x130
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410690]
[<ffffffffa01b5681>] ? ixgbe_rx_skb+0x41/0xd0 [ixgbe]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410701]
[<ffffffffa01b697c>] ? ixgbe_clean_rx_irq+0x10c/0x1d0 [ixgbe]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410712]
[<ffffffffa01b6f15>] ? ixgbe_poll+0xa5/0x130 [ixgbe]
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410716]
[<ffffffff8143ad6a>] ? net_rx_action+0x14a/0x230
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410721]
[<ffffffff810dd2e1>] ? rcu_check_quiescent_state+0x21/0x60
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410725]
[<ffffffff81075e09>] ? __do_softirq+0xb9/0x1d0
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410729]
[<ffffffff810dcdae>] ? rcu_irq_exit+0xe/0x10
Aug  8 15:37:38 scad01adm01 kernel: [ 1884.410733]
[<ffffffff8151053c>] ? call_softirq+0x1c/0x30

Another Trace:

Aug  9 14:12:05 scad01adm01 kernel: [82985.293794] Call Trace:
Aug  9 14:12:05 scad01adm01 kernel: [82985.293795]  <IRQ>
Aug  9 14:12:05 scad01adm01 kernel: [82985.293800]
[<ffffffff8125c65d>] delay_tsc+0x4d/0x80
Aug  9 14:12:05 scad01adm01 kernel: [82985.293804]
[<ffffffff8125c5cf>] __delay+0xf/0x20
Aug  9 14:12:05 scad01adm01 kernel: [82985.293807]
[<ffffffff8125c60c>] __const_udelay+0x2c/0x30
Aug  9 14:12:05 scad01adm01 kernel: [82985.293814]
[<ffffffff8132b8b0>] wait_for_xmitr+0x30/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293818]
[<ffffffff8132b920>] ? wait_for_xmitr+0xa0/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293822]
[<ffffffff8132b946>] serial8250_console_putchar+0x26/0x40
Aug  9 14:12:05 scad01adm01 kernel: [82985.293826]
[<ffffffff8132742d>] uart_console_write+0x3d/0x70
Aug  9 14:12:05 scad01adm01 kernel: [82985.293831]
[<ffffffff8132d3a2>] serial8250_console_write+0xc2/0x150
Aug  9 14:12:05 scad01adm01 kernel: [82985.293839]
[<ffffffff8106f66e>] __call_console_drivers+0x8e/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293843]
[<ffffffff8106f6ca>] _call_console_drivers+0x4a/0x80
Aug  9 14:12:05 scad01adm01 kernel: [82985.293847]
[<ffffffff8106f9f2>] call_console_drivers+0x82/0x130
Aug  9 14:12:05 scad01adm01 kernel: [82985.293853]
[<ffffffff81506b84>] ? _raw_spin_lock_irqsave+0x34/0x50
Aug  9 14:12:05 scad01adm01 kernel: [82985.293858]
[<ffffffff8106fd4a>] console_unlock+0x5a/0x110
Aug  9 14:12:05 scad01adm01 kernel: [82985.293862]
[<ffffffff81070422>] vprintk+0x1a2/0x3a0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293872]
[<ffffffff810dcdae>] ? rcu_irq_exit+0xe/0x10
Aug  9 14:12:05 scad01adm01 kernel: [82985.293876]
[<ffffffff8107068c>] printk+0x6c/0x70
Aug  9 14:12:05 scad01adm01 kernel: [82985.293882]
[<ffffffff8122838a>] ? sha1_update+0xba/0x100
Aug  9 14:12:05 scad01adm01 kernel: [82985.293887]
[<ffffffff810dd8a2>] print_cpu_stall+0x42/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293891]
[<ffffffff810ddb2a>] check_cpu_stall+0xca/0xe0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293896]
[<ffffffff810ddb70>] __rcu_pending+0x30/0x140
Aug  9 14:12:05 scad01adm01 kernel: [82985.293900]
[<ffffffff810ddcb7>] rcu_pending+0x37/0x90
Aug  9 14:12:05 scad01adm01 kernel: [82985.293905]
[<ffffffff810dde95>] rcu_check_callbacks+0x85/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293914]
[<ffffffff8107e7b6>] update_process_times+0x46/0x90
Aug  9 14:12:05 scad01adm01 kernel: [82985.293923]
[<ffffffff810a31d6>] tick_sched_timer+0x66/0xd0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293927]
[<ffffffff810a3170>] ? tick_clock_notify+0x60/0x60
Aug  9 14:12:05 scad01adm01 kernel: [82985.293933]
[<ffffffff81095c63>] __run_hrtimer+0x83/0x1e0
Aug  9 14:12:05 scad01adm01 kernel: [82985.293937]
[<ffffffff81095f76>] hrtimer_interrupt+0xe6/0x240
Aug  9 14:12:05 scad01adm01 kernel: [82985.293945]
[<ffffffff81033e6b>] local_apic_timer_interrupt+0x3b/0x70
Aug  9 14:12:05 scad01adm01 kernel: [82985.293950]
[<ffffffff81510e65>] smp_apic_timer_interrupt+0x45/0x5a
Aug  9 14:12:05 scad01adm01 kernel: [82985.293953]
[<ffffffff8150fcf3>] apic_timer_interrupt+0x13/0x20
Aug  9 14:12:05 scad01adm01 kernel: [82985.293958]
[<ffffffff8125d33b>] ? memcpy+0xb/0x120
Aug  9 14:12:05 scad01adm01 kernel: [82985.293963]
[<ffffffff81220f76>] ? blkcipher_walk_done+0x196/0x240
Aug  9 14:12:05 scad01adm01 kernel: [82985.293969]
[<ffffffffa05a1710>] ? dec128+0x818/0x818 [aes_x86_64]
Aug  9 14:12:05 scad01adm01 kernel: [82985.293974]
[<ffffffffa05d551b>] ? crypto_cbc_decrypt+0x5b/0x90 [cbc]
Aug  9 14:12:05 scad01adm01 kernel: [82985.293978]
[<ffffffff8122195d>] ? async_decrypt+0x3d/0x40
Aug  9 14:12:05 scad01adm01 kernel: [82985.293983]
[<ffffffffa0643e08>] ? crypto_authenc_decrypt+0xa8/0xb0 [authenc]
Aug  9 14:12:05 scad01adm01 kernel: [82985.293989]
[<ffffffffa0578fc8>] ? esp_input+0x1e8/0x350 [esp4]
Aug  9 14:12:05 scad01adm01 kernel: [82985.293994]
[<ffffffff814c3fe9>] ? xfrm_state_lookup+0x69/0x90
Aug  9 14:12:05 scad01adm01 kernel: [82985.293998]
[<ffffffff814c7c31>] ? xfrm_input+0x691/0x6e0
Aug  9 14:12:05 scad01adm01 kernel: [82985.294003]
[<ffffffff814bb950>] ? xfrm4_rcv_encap+0x20/0x30
Aug  9 14:12:05 scad01adm01 kernel: [82985.294007]
[<ffffffff814bb9a4>] ? xfrm4_rcv+0x24/0x30
Aug  9 14:12:05 scad01adm01 kernel: [82985.294012]
[<ffffffff8146f399>] ? ip_local_deliver_finish+0x129/0x280
Aug  9 14:12:05 scad01adm01 kernel: [82985.294016]
[<ffffffff8146eef0>] ? ip_local_deliver+0x40/0xa0
Aug  9 14:12:05 scad01adm01 kernel: [82985.294019]
[<ffffffff8146f669>] ? ip_rcv_finish+0x179/0x380
Aug  9 14:12:05 scad01adm01 kernel: [82985.294023]
[<ffffffff8146f172>] ? ip_rcv+0x222/0x320
Aug  9 14:12:05 scad01adm01 kernel: [82985.294030]
[<ffffffff814393ab>] ? __netif_receive_skb+0x25b/0x500
Aug  9 14:12:05 scad01adm01 kernel: [82985.294035]
[<ffffffff8143a58d>] ? netif_receive_skb+0x7d/0x90
Aug  9 14:12:05 scad01adm01 kernel: [82985.294043]
[<ffffffff8126aa7d>] ? swiotlb_sync_single+0x2d/0x70
Aug  9 14:12:05 scad01adm01 kernel: [82985.294047]
[<ffffffff8143a678>] ? napi_skb_finish+0x48/0x60
Aug  9 14:12:05 scad01adm01 kernel: [82985.294051]
[<ffffffff8143ab1b>] ? napi_gro_receive+0xfb/0x130
Aug  9 14:12:05 scad01adm01 kernel: [82985.294073]
[<ffffffffa01b5681>] ? ixgbe_rx_skb+0x41/0xd0 [ixgbe]
Aug  9 14:12:05 scad01adm01 kernel: [82985.294085]
[<ffffffffa01b697c>] ? ixgbe_clean_rx_irq+0x10c/0x1d0 [ixgbe]
Aug  9 14:12:05 scad01adm01 kernel: [82985.294097]
[<ffffffffa01b6f15>] ? ixgbe_poll+0xa5/0x130 [ixgbe]
Aug  9 14:12:05 scad01adm01 kernel: [82985.294101]
[<ffffffff8143ad6a>] ? net_rx_action+0x14a/0x230
Aug  9 14:12:05 scad01adm01 kernel: [82985.294106]
[<ffffffff81075e09>] ? __do_softirq+0xb9/0x1d0
Aug  9 14:12:05 scad01adm01 kernel: [82985.294110]
[<ffffffff8151053c>] ? call_softirq+0x1c/0x30
Aug  9 14:12:05 scad01adm01 kernel: [82985.294112]  <EOI>

-- 
JS
