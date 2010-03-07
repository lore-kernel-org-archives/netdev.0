From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: inconsistent lock state
Date: Sun, 7 Mar 2010 12:21:58 +0200
Message-ID: <20100307102157.GA8284@swordfish>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Hardly reproducible.
/*
* 2.6.33. x86. ASUS f3jc=20
*/

[329645.010697] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[329645.010699] [ INFO: inconsistent lock state ]
[329645.010703] 2.6.33-33-0-dbg #31
[329645.010705] ---------------------------------
[329645.010708] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[329645.010712] events/0/9 [HC0[0]:SC0[0]:HE1:SE1] takes:
[329645.010715]  (&(&table->hash[i].lock)->rlock){+.?.-.}, at: [<c12c1892>]=
 spin_lock+0x8/0xa
[329645.010729] {IN-SOFTIRQ-W} state was registered at:
[329645.010732]   [<c105878f>] __lock_acquire+0x27e/0xb86
[329645.010739]   [<c1059988>] lock_acquire+0xa1/0xb8
[329645.010744]   [<c12f39b2>] _raw_spin_lock+0x28/0x58
[329645.010750]   [<c12c1892>] spin_lock+0x8/0xa
[329645.010755]   [<c12c2c8f>] T.958+0x3c/0x141
[329645.010759]   [<c12c2f7a>] __udp4_lib_rcv+0x1e6/0x3cd
[329645.010764]   [<c12c3173>] udp_rcv+0x12/0x14
[329645.010769]   [<c12a559b>] ip_local_deliver_finish+0xc9/0x130
[329645.010774]   [<c12a5663>] ip_local_deliver+0x61/0x66
[329645.010778]   [<c12a51a5>] ip_rcv_finish+0x275/0x29d
[329645.010783]   [<c12a539a>] ip_rcv+0x1cd/0x1ed
[329645.010786]   [<c128858d>] netif_receive_skb+0x340/0x360
[329645.010791]   [<fd1ab6f4>] rtl8169_rx_interrupt+0x2bf/0x37e [r8169]
[329645.010801]   [<fd1adab8>] rtl8169_poll+0x29/0x15a [r8169]
[329645.010808]   [<c1288b8c>] net_rx_action+0x95/0x1af
[329645.010812]   [<c1037243>] __do_softirq+0xc6/0x187
[329645.010819]   [<c103732f>] do_softirq+0x2b/0x43
[329645.010823]   [<c10374bf>] irq_exit+0x38/0x75
[329645.010828]   [<c1004116>] do_IRQ+0x88/0x9c
[329645.010833]   [<c1002f35>] common_interrupt+0x35/0x3c
[329645.010837]   [<c1275d0b>] cpuidle_idle_call+0x72/0xd3
[329645.010844]   [<c1001c1b>] cpu_idle+0x92/0xbf
[329645.010848]   [<c12e3f16>] rest_init+0x76/0x78
[329645.010853]   [<c14c2868>] start_kernel+0x33c/0x341
[329645.010859]   [<c14c2092>] i386_start_kernel+0x92/0x99
[329645.010864] irq event stamp: 157782307
[329645.010866] hardirqs last  enabled at (157782307): [<c10b74b8>] kmem_ca=
che_free+0x97/0xd6
[329645.010873] hardirqs last disabled at (157782306): [<c10b745a>] kmem_ca=
che_free+0x39/0xd6
[329645.010878] softirqs last  enabled at (157782304): [<c12928ef>] rcu_rea=
d_unlock_bh+0x1c/0x1e
[329645.010885] softirqs last disabled at (157782302): [<c129289b>] rcu_rea=
d_lock_bh+0x8/0x26
[329645.010892]=20
[329645.010893] other info that might help us debug this:
[329645.010896] 5 locks held by events/0/9:
[329645.010898]  #0:  (events){+.+.+.}, at: [<c1044f2f>] worker_thread+0x16=
a/0x27c
[329645.010908]  #1:  ((&(&tp->task)->work)){+.+...}, at: [<c1044f2f>] work=
er_thread+0x16a/0x27c
[329645.010915]  #2:  (rtnl_mutex){+.+.+.}, at: [<c12911dd>] rtnl_lock+0xf/=
0x11
[329645.010922]  #3:  (rcu_read_lock){.+.+..}, at: [<c1286a01>] rcu_read_lo=
ck+0x0/0x2b
[329645.010931]  #4:  (rcu_read_lock){.+.+..}, at: [<c12a4ed0>] rcu_read_lo=
ck+0x0/0x2b
[329645.010938]=20
[329645.010939] stack backtrace:
[329645.010942] Pid: 9, comm: events/0 Not tainted 2.6.33-33-0-dbg #31
[329645.010945] Call Trace:
[329645.010950]  [<c12f18ec>] ? printk+0xf/0x11
[329645.010955]  [<c1057800>] valid_state+0x12a/0x13d
[329645.010960]  [<c1057904>] mark_lock+0xf1/0x1e2
[329645.010965]  [<c1057ffa>] ? check_usage_backwards+0x0/0x6f
[329645.010970]  [<c10587fd>] __lock_acquire+0x2ec/0xb86
[329645.010976]  [<c100864f>] ? native_sched_clock+0x48/0x8d
[329645.010982]  [<c104d24b>] ? sched_clock_local+0x17/0x11e
[329645.010987]  [<c12c1892>] ? spin_lock+0x8/0xa
[329645.010992]  [<c1059988>] lock_acquire+0xa1/0xb8
[329645.010997]  [<c12c1892>] ? spin_lock+0x8/0xa
[329645.011002]  [<c12f39b2>] _raw_spin_lock+0x28/0x58
[329645.011006]  [<c12c1892>] ? spin_lock+0x8/0xa
[329645.011010]  [<c12c1892>] spin_lock+0x8/0xa
[329645.011015]  [<c12c2c8f>] T.958+0x3c/0x141
[329645.011020]  [<c104d472>] ? sched_clock_cpu+0x120/0x128
[329645.011025]  [<c100864f>] ? native_sched_clock+0x48/0x8d
[329645.011031]  [<c1059088>] ? __lock_acquire+0xb77/0xb86
[329645.011037]  [<c12a1345>] ? rcu_read_unlock+0x0/0x35
[329645.011042]  [<c12a38c0>] ? ip_route_input+0x102/0xacb
[329645.011046]  [<c1057831>] ? mark_lock+0x1e/0x1e2
[329645.011051]  [<c12a4ed0>] ? rcu_read_lock+0x0/0x2b
[329645.011056]  [<c12c2f7a>] __udp4_lib_rcv+0x1e6/0x3cd
[329645.011061]  [<c12c3173>] udp_rcv+0x12/0x14
[329645.011065]  [<c12a559b>] ip_local_deliver_finish+0xc9/0x130
[329645.011070]  [<c12a5663>] ip_local_deliver+0x61/0x66
[329645.011074]  [<c12a51a5>] ip_rcv_finish+0x275/0x29d
[329645.011078]  [<c12a539a>] ip_rcv+0x1cd/0x1ed
[329645.011083]  [<c128858d>] netif_receive_skb+0x340/0x360
[329645.011093]  [<fd1ab6f4>] rtl8169_rx_interrupt+0x2bf/0x37e [r8169]
[329645.011100]  [<fd1aba02>] rtl8169_reset_task+0x38/0xcd [r8169]
[329645.011105]  [<c1044f71>] worker_thread+0x1ac/0x27c
[329645.011110]  [<c1044f2f>] ? worker_thread+0x16a/0x27c
[329645.011116]  [<fd1ab9ca>] ? rtl8169_reset_task+0x0/0xcd [r8169]
[329645.011123]  [<c1048725>] ? autoremove_wake_function+0x0/0x2f
[329645.011128]  [<c1044dc5>] ? worker_thread+0x0/0x27c
[329645.011132]  [<c104838a>] kthread+0x6a/0x6f
[329645.011137]  [<c1048320>] ? kthread+0x0/0x6f
[329645.011142]  [<c1002f42>] kernel_thread_helper+0x6/0x1a



	Sergey
--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuTfkUACgkQfKHnntdSXjTtLAP+MYCMqEhSY0dzOsJDp4gh6qwu
7CRV/e8yPNrnJXC2Wbo6Zo2A4qi9ExhEpog10Rf0unpREwtBSbahcMwbbQNJlVcB
+6G9fobnw82xtik1sjBcwfLvyYLdww84huA30fJmLTF75abPQ7nSefg6s+iSDlkP
dnZ1qvNQWe/0HF6zi3o=
=0w7v
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
