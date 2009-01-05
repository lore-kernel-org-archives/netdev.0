From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to request_firmware()
Date: Mon, 05 Jan 2009 14:58:11 +0100
Message-ID: <496211F3.3000003@hartkopp.net>
References: <1230626497.24796.26.camel@jaswinder.satnam> <49620AFE.6040409@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020105050708070105090509"
Cc: davem@redhat.com, jgarzik@redhat.com,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org,
	mchan@broadcom.com
To: Jaswinder Singh Rajput <jaswinder@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <49620AFE.6040409@hartkopp.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020105050708070105090509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Oliver Hartkopp wrote:
>  
>
> 2. I got this inconsistent lock state, i've not seen before:
>

Hm - that was not completely correct 8->

I found some more of these lock state issues in my /var/log/kern.log but 
all of them are in the tg3 receive path ... (attached).

So this problem seems not to come from your request_firmware() 
conversion. Maybe there was some other change in the 2.6.28-git that 
causes these tg3 problems.

Regards,
Oliver





--------------020105050708070105090509
Content-Type: text/plain;
 name="tg3lockstate1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3lockstate1"

Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752455] 
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752459] =================================
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752467] [ INFO: inconsistent lock state ]
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752473] 2.6.28-05692-g7d3b56b #4
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752477] ---------------------------------
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752483] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752490] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752495]  (&fbc->lock){-+..}, at: [<c0223d5b>] __percpu_counter_add+0x52/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752514] {softirq-on-W} state was registered at:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752518]   [<c0140000>] __lock_acquire+0x2c4/0xb22
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752530]   [<c01408bb>] lock_acquire+0x5d/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752540]   [<c03b9601>] _spin_lock+0x1b/0x2a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752550]   [<c0223d90>] __percpu_counter_sum+0xd/0x51
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752559]   [<c01b4f23>] ext3_statfs+0xb5/0x159
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752568]   [<c0172964>] vfs_statfs+0x3c/0x55
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752577]   [<c0173c09>] sys_statfs64+0x44/0x80
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752587]   [<c0102ed5>] sysenter_do_call+0x12/0x35
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752596]   [<ffffffff>] 0xffffffff
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752613] irq event stamp: 566114
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752618] hardirqs last  enabled at (566114): [<c0155c1c>] free_hot_cold_page+0x138/0x163
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752629] hardirqs last disabled at (566113): [<c0155b67>] free_hot_cold_page+0x83/0x163
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752639] softirqs last  enabled at (566060): [<c01279db>] __do_softirq+0x135/0x13d
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752651] softirqs last disabled at (566083): [<c0127a1d>] do_softirq+0x3a/0x52
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752661] 
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752663] other info that might help us debug this:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752669] 3 locks held by swapper/0:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752673]  #0:  (rcu_read_lock){..--}, at: [<c032b4df>] netif_receive_skb+0xb0/0x25f
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752690]  #1:  (rcu_read_lock){..--}, at: [<c033f210>] ip_local_deliver+0x49/0x145
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752706]  #2:  (slock-AF_INET/1){-+..}, at: [<c03553af>] tcp_v4_rcv+0x20b/0x4fd
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752724] 
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752726] stack backtrace:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752732] Pid: 0, comm: swapper Not tainted 2.6.28-05692-g7d3b56b #4
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752738] Call Trace:
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752748]  [<c03b75cb>] ? printk+0xf/0x11
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752757]  [<c013f061>] valid_state+0x12a/0x13d
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752766]  [<c013f31c>] mark_lock+0x133/0x340
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752776]  [<c013ff7e>] __lock_acquire+0x242/0xb22
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752785]  [<c013f207>] ? mark_lock+0x1e/0x340
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752794]  [<c013f57c>] ? mark_held_locks+0x53/0x6a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752803]  [<c01408bb>] lock_acquire+0x5d/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752812]  [<c0223d5b>] ? __percpu_counter_add+0x52/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752820]  [<c03b9601>] _spin_lock+0x1b/0x2a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752828]  [<c0223d5b>] ? __percpu_counter_add+0x52/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752837]  [<c0223d5b>] __percpu_counter_add+0x52/0x7a
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752845]  [<c0354dc4>] tcp_v4_destroy_sock+0x15b/0x164
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752854]  [<c0345e64>] inet_csk_destroy_sock+0x87/0xf4
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752862]  [<c03476b2>] tcp_done+0x5d/0x60
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752872]  [<c0350153>] tcp_rcv_state_process+0x7a6/0x883
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752880]  [<c03553af>] ? tcp_v4_rcv+0x20b/0x4fd
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752887]  [<c035515b>] tcp_v4_do_rcv+0x114/0x15d
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752895]  [<c03554be>] tcp_v4_rcv+0x31a/0x4fd
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752904]  [<c033f279>] ip_local_deliver+0xb2/0x145
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752911]  [<c033f149>] ip_rcv+0x3d1/0x3fb
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752921]  [<c03949b1>] ? packet_rcv_spkt+0x9c/0xa4
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752930]  [<c032b65b>] netif_receive_skb+0x22c/0x25f
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752940]  [<c02a09b1>] tg3_poll+0x6a6/0x8bf
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752949]  [<c032a3a0>] net_rx_action+0x62/0x143
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752958]  [<c0127935>] __do_softirq+0x8f/0x13d
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752966]  [<c0127a1d>] do_softirq+0x3a/0x52
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752975]  [<c0127b43>] irq_exit+0x44/0x7b
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752983]  [<c0104c7e>] do_IRQ+0x92/0xa8
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.752991]  [<c010352c>] common_interrupt+0x2c/0x34
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753001]  [<c013007b>] ? ____call_usermodehelper+0x85/0x124
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753011]  [<c0261acd>] ? acpi_idle_enter_simple+0x151/0x182
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753021]  [<c026179e>] acpi_idle_enter_bm+0xc6/0x2a4
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753032]  [<c031475d>] cpuidle_idle_call+0x60/0x93
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753039]  [<c01020c5>] cpu_idle+0x73/0x96
Jan  4 15:02:48 vwagwolkf320 kernel: [  112.753048]  [<c03b4ef7>] start_secondary+0x19c/0x1a4

--------------020105050708070105090509
Content-Type: text/plain;
 name="tg3lockstate2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3lockstate2"

Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800876] 
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800878] =================================
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800884] [ INFO: inconsistent lock state ]
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800888] 2.6.28-03164-g11df0b0 #6
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800891] ---------------------------------
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800894] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800899] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800902]  (&fbc->lock){-+..}, at: [<c0222900>] __percpu_counter_add+0x52/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800915] {softirq-on-W} state was registered at:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800919]   [<c013fe6f>] __lock_acquire+0x2a6/0xadd
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800926]   [<c0140703>] lock_acquire+0x5d/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800933]   [<c03b75e9>] _spin_lock+0x1b/0x2a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800939]   [<c0222871>] __percpu_counter_sum+0xd/0x4a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800949]   [<c01b425b>] ext3_statfs+0xb5/0x159
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800953]   [<c01724bc>] vfs_statfs+0x3c/0x55
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800958]   [<c0173751>] sys_statfs64+0x44/0x80
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800961]   [<c0102fd5>] sysenter_do_call+0x12/0x35
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800965]   [<ffffffff>] 0xffffffff
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800974] irq event stamp: 976438
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800976] hardirqs last  enabled at (976438): [<c0155959>] free_hot_cold_page+0x138/0x163
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800980] hardirqs last disabled at (976437): [<c01558a4>] free_hot_cold_page+0x83/0x163
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800984] softirqs last  enabled at (976396): [<c012794a>] __do_softirq+0x135/0x13d
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800989] softirqs last disabled at (976407): [<c012798c>] do_softirq+0x3a/0x52
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800993] 
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800994] other info that might help us debug this:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800996] 3 locks held by swapper/0:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.800998]  #0:  (rcu_read_lock){..--}, at: [<c0329b36>] netif_receive_skb+0xb0/0x25f
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801005]  #1:  (rcu_read_lock){..--}, at: [<c033d820>] ip_local_deliver+0x49/0x145
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801011]  #2:  (slock-AF_INET/1){-+..}, at: [<c0353853>] tcp_v4_rcv+0x20b/0x4fd
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801019] 
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801019] stack backtrace:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801022] Pid: 0, comm: swapper Not tainted 2.6.28-03164-g11df0b0 #6
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801024] Call Trace:
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801028]  [<c03b5735>] ? printk+0xf/0x11
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801032]  [<c013eda5>] valid_state+0x12a/0x13d
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801036]  [<c013f1f7>] mark_lock+0x133/0x330
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801039]  [<c013fdf2>] __lock_acquire+0x229/0xadd
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801043]  [<c013f0e2>] ? mark_lock+0x1e/0x330
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801046]  [<c013f447>] ? mark_held_locks+0x53/0x6a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801050]  [<c0140703>] lock_acquire+0x5d/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801053]  [<c0222900>] ? __percpu_counter_add+0x52/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801056]  [<c03b75e9>] _spin_lock+0x1b/0x2a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801060]  [<c0222900>] ? __percpu_counter_add+0x52/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801063]  [<c0222900>] __percpu_counter_add+0x52/0x7a
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801067]  [<c0353268>] tcp_v4_destroy_sock+0x15b/0x164
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801071]  [<c0344403>] inet_csk_destroy_sock+0x73/0xe0
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801074]  [<c0345c02>] tcp_done+0x5d/0x60
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801078]  [<c034e5fe>] tcp_rcv_state_process+0x7a6/0x884
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801081]  [<c0353853>] ? tcp_v4_rcv+0x20b/0x4fd
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801084]  [<c03535ff>] tcp_v4_do_rcv+0x114/0x15d
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801087]  [<c0353962>] tcp_v4_rcv+0x31a/0x4fd
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801090]  [<c033d889>] ip_local_deliver+0xb2/0x145
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801093]  [<c033d759>] ip_rcv+0x3d1/0x3fb
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801097]  [<c0392be7>] ? packet_rcv_spkt+0x9c/0xa4
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801100]  [<c0329cb2>] netif_receive_skb+0x22c/0x25f
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801104]  [<c029e797>] tg3_poll+0x6a6/0x8bf
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801109]  [<c0328a0a>] net_rx_action+0x62/0x13e
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801112]  [<c01278a4>] __do_softirq+0x8f/0x13d
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801116]  [<c012798c>] do_softirq+0x3a/0x52
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801119]  [<c0127ab0>] irq_exit+0x44/0x83
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801122]  [<c0104d32>] do_IRQ+0x96/0xac
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801125]  [<c010362c>] common_interrupt+0x2c/0x34
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801130]  [<c013007b>] ? usermodehelper_disable+0x89/0xa3
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801134]  [<c02606a2>] ? acpi_idle_enter_simple+0x151/0x182
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801138]  [<c0260373>] acpi_idle_enter_bm+0xc6/0x2a4
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801142]  [<c0312f5d>] cpuidle_idle_call+0x60/0x93
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801145]  [<c0102139>] cpu_idle+0x70/0x93
Jan  4 15:49:56 vwagwolkf320 kernel: [  374.801149]  [<c03b2fae>] start_secondary+0x19a/0x1a2

--------------020105050708070105090509--
