From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-08-11 - lockdep whinges at e1000e driver ifconfig up
Date: Thu, 12 Aug 2010 12:37:58 -0400
Message-ID: <11448.1281631078@localhost>
References: <201008112340.o7BNenDe021017@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1281631078_11114P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, netfilter@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	kaber@trash.net, jengelh@medozas.de, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:54335 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab0HLQkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 12:40:49 -0400
In-Reply-To: Your message of "Wed, 11 Aug 2010 16:10:49 PDT."
             <201008112340.o7BNenDe021017@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1281631078_11114P
Content-Type: text/plain; charset=us-ascii

On Wed, 11 Aug 2010 16:10:49 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-08-11-16-10 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Not sure if it's an e1000e bug, or an iptables bug that happened to trip on
like the first few packets accepted after the interface came up, so I'll cc:
everybody and let ya'll fight over it. :)

[  431.011194] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
[  431.062183] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
[  431.064607] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  432.691161] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
[  432.691177] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO
[  432.695461] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  432.697278] 
[  432.697279] =================================
[  432.697477] [ INFO: inconsistent lock state ]
[  432.697581] 2.6.35-mmotm0811 #1
[  432.697682] ---------------------------------
[  432.697785] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[  432.697890] kworker/0:0/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
[  432.697994]  (&(&lock->lock)->rlock){+.?...}, at: [<ffffffff814d39c8>] ip6t_do_table+0xc1/0x646
[  432.698028] {SOFTIRQ-ON-W} state was registered at:
[  432.698028]   [<ffffffff8106762f>] __lock_acquire+0x3a3/0xd6a
[  432.698028]   [<ffffffff81068514>] lock_acquire+0x10a/0x130
[  432.698028]   [<ffffffff81557cd9>] _raw_spin_lock+0x36/0x45
[  432.698028]   [<ffffffff814d3375>] xt_info_wrlock+0x1c/0x1e
[  432.698028]   [<ffffffff814d48df>] get_counters+0x93/0x14a
[  432.698028]   [<ffffffff814d49c3>] alloc_counters.clone.3+0x2d/0x41
[  432.698028]   [<ffffffff814d4f98>] do_ip6t_get_ctl+0x110/0x367
[  432.698028]   [<ffffffff814402a7>] nf_sockopt+0x5c/0x88
[  432.698028]   [<ffffffff814402e6>] nf_getsockopt+0x13/0x15
[  432.698028]   [<ffffffff814ba05e>] ipv6_getsockopt+0x94/0xc3
[  432.698028]   [<ffffffff814c1175>] rawv6_getsockopt+0x48/0x54
[  432.698028]   [<ffffffff8141533a>] sock_common_getsockopt+0xf/0x11
[  432.698028]   [<ffffffff814147dd>] sys_getsockopt+0x75/0x93
[  432.698028]   [<ffffffff8100272b>] system_call_fastpath+0x16/0x1b
[  432.698028] irq event stamp: 3554312
[  432.698028] hardirqs last  enabled at (3554312): [<ffffffff8103fcb9>] _local_bh_enable_ip+0x139/0x178
[  432.698028] hardirqs last disabled at (3554311): [<ffffffff8103fc3a>] _local_bh_enable_ip+0xba/0x178
[  432.698028] softirqs last  enabled at (3554260): [<ffffffff81040282>] __do_softirq+0x273/0x289
[  432.698028] softirqs last disabled at (3554277): [<ffffffff8100364c>] call_softirq+0x1c/0x28
[  432.698028] 
[  432.698028] other info that might help us debug this:
[  432.698028] 3 locks held by kworker/0:0/0:
[  432.698028]  #0:  (&idev->mc_ifc_timer){+.-...}, at: [<ffffffff810468f9>] run_timer_softirq+0x1d2/0x442
[  432.698028]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff814c3c2a>] rcu_read_lock+0x0/0x35
[  432.698028]  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff8143e840>] rcu_read_lock+0x0/0x35
[  432.698028] 
[  432.698028] stack backtrace:
[  432.698028] Pid: 0, comm: kworker/0:0 Not tainted 2.6.35-mmotm0811 #1
[  432.698028] Call Trace:
[  432.698028]  <IRQ>  [<ffffffff810670a2>] valid_state+0x17c/0x18e
[  432.698028]  [<ffffffff81066967>] ? check_usage_forwards+0x0/0x87
[  432.698028]  [<ffffffff81067193>] mark_lock+0xdf/0x1d8
[  432.698028]  [<ffffffff810675b1>] __lock_acquire+0x325/0xd6a
[  432.698028]  [<ffffffff8106768f>] ? __lock_acquire+0x403/0xd6a
[  432.698028]  [<ffffffff810687fc>] ? mark_held_locks+0x50/0x72
[  432.698028]  [<ffffffff814d39c8>] ? ip6t_do_table+0xc1/0x646
[  432.698028]  [<ffffffff81068514>] lock_acquire+0x10a/0x130
[  432.698028]  [<ffffffff814d39c8>] ? ip6t_do_table+0xc1/0x646
[  432.698028]  [<ffffffff8103fce6>] ? _local_bh_enable_ip+0x166/0x178
[  432.698028]  [<ffffffff81557cd9>] _raw_spin_lock+0x36/0x45
[  432.698028]  [<ffffffff814d39c8>] ? ip6t_do_table+0xc1/0x646
[  432.698028]  [<ffffffff814d39c8>] ip6t_do_table+0xc1/0x646
[  432.698028]  [<ffffffff8103fce6>] ? _local_bh_enable_ip+0x166/0x178
[  432.698028]  [<ffffffff8103fd10>] ? local_bh_enable+0xd/0xf
[  432.698028]  [<ffffffff8144234b>] ? nf_conntrack_in+0x4a9/0x5b9
[  432.698028]  [<ffffffff814d5ee7>] ip6table_filter_hook+0x17/0x1c
[  432.698028]  [<ffffffff8143ec43>] nf_iterate+0x41/0x84
[  432.698028]  [<ffffffff814c3ec5>] ? dst_output+0x0/0x70
[  432.698028]  [<ffffffff8143ecf9>] nf_hook_slow+0x73/0xde
[  432.698028]  [<ffffffff814c3ec5>] ? dst_output+0x0/0x70
[  432.698028]  [<ffffffff8104710a>] ? msleep_interruptible+0x5b/0x72
[  432.698028]  [<ffffffff814c508e>] NF_HOOK.clone.21+0x3e/0x52
[  432.698028]  [<ffffffff81499c6c>] ? xfrm_lookup+0x11/0x2e
[  432.698028]  [<ffffffff814c531f>] mld_sendpack+0x27d/0x3dd
[  432.698028]  [<ffffffff814c5ad6>] mld_ifc_timer_expire+0x1ca/0x207
[  432.698028]  [<ffffffff810469eb>] run_timer_softirq+0x2c4/0x442
[  432.698028]  [<ffffffff810468f9>] ? run_timer_softirq+0x1d2/0x442
[  432.698028]  [<ffffffff81059222>] ? __run_hrtimer+0x1ec/0x234
[  432.698028]  [<ffffffff814c590c>] ? mld_ifc_timer_expire+0x0/0x207
[  432.698028]  [<ffffffff81040080>] ? __do_softirq+0x71/0x289
[  432.698028]  [<ffffffff81040155>] __do_softirq+0x146/0x289
[  432.698028]  [<ffffffff810a29bc>] ? time_hardirqs_off+0x1b/0x2f
[  432.698028]  [<ffffffff8100364c>] call_softirq+0x1c/0x28
[  432.698028]  [<ffffffff81004bc3>] do_softirq+0x44/0xf1
[  432.698028]  [<ffffffff8104035a>] irq_exit+0x4a/0xb4
[  432.698028]  [<ffffffff8101a3dd>] smp_apic_timer_interrupt+0x79/0x87
[  432.698028]  [<ffffffff81003113>] apic_timer_interrupt+0x13/0x20
[  432.698028]  <EOI>  [<ffffffff81277630>] ? acpi_idle_enter_simple+0x122/0x15a
[  432.698028]  [<ffffffff8127762b>] ? acpi_idle_enter_simple+0x11d/0x15a
[  432.698028]  [<ffffffff813b9c3c>] cpuidle_idle_call+0x9b/0x15d
[  432.698028]  [<ffffffff81000c73>] cpu_idle+0x85/0x169
[  432.698028]  [<ffffffff81b5e906>] start_secondary+0x1b1/0x1b5
[  497.031095] ADDRCONF(NETDEV_UP): wlan0: link is not ready



--==_Exmh_1281631078_11114P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMZCNmcC3lWbTT17ARArmmAJwIKhdlE6FNWckj9I16657G1iKQ2QCgzzlA
LUUBRJ6Qv6WYNOHEgKJIRfM=
=pciC
-----END PGP SIGNATURE-----

--==_Exmh_1281631078_11114P--

