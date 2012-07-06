From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: net-next warning at kernel/softirq.c:159 local_bh_enable
Date: Fri, 6 Jul 2012 07:17:33 +0300
Message-ID: <alpine.LRH.2.00.1207060716390.32599@ogerlitz.voltaire.com>
References: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, Shlomo Pongratz <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:49576 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751237Ab2GFESC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 00:18:02 -0400
In-Reply-To: <alpine.LRH.2.00.1207060616590.21283@ogerlitz.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW - I've updated my net-next clone to the lastest and still
see this, even after the IPv6 related fix.

Or.


IPv6: ADDRCONF(NETDEV_UP): ib0: link is not ready
IPv6: ADDRCONF(NETDEV_CHANGE): ib0: link becomes ready
------------[ cut here ]------------
WARNING: at kernel/softirq.c:159 local_bh_enable+0x45/0xc2()
Hardware name: X7DWU
Modules linked in: ib_ipoib ib_cm ib_sa ib_uverbs netconsole nfs lockd auth_rpcgss nfs_acl autofs4 sunrpc fcoe libfcoe libfc scsi_transport_fc 8021q ipmi_devintf ipmi_si ipmi_msghandler ipv6 dm_mirror dm_region_hash dm_log uinput igb ptp pps_core mlx4_ib ib_mad ib_core mlx4_en mlx4_core sg kvm_intel kvm microcode pcspkr rng_core ioatdma dca dm_mod shpchp button sr_mod ext3 jbd usb_storage sd_mod ata_piix libata scsi_mod ehci_hcd uhci_hcd floppy [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc5-12501-g1405080-dirty #86
Call Trace:
 <IRQ>  [<ffffffff81027f1d>] warn_slowpath_common+0x80/0x98
 [<ffffffffa0245266>] ? ip6_neigh_lookup+0x157/0x187 [ipv6]
 [<ffffffff81027f4a>] warn_slowpath_null+0x15/0x17
 [<ffffffff8102f56a>] local_bh_enable+0x45/0xc2
 [<ffffffffa0245266>] ip6_neigh_lookup+0x157/0x187 [ipv6]
 [<ffffffffa0245168>] ? ip6_neigh_lookup+0x59/0x187 [ipv6]
 [<ffffffffa030895d>] ipoib_mcast_send+0x375/0x48b [ib_ipoib]
 [<ffffffffa0308908>] ? ipoib_mcast_send+0x320/0x48b [ib_ipoib]
 [<ffffffff8102f5e2>] ? local_bh_enable+0xbd/0xc2
 [<ffffffffa030494f>] ipoib_path_lookup+0x2f3/0x331 [ib_ipoib]
 [<ffffffffa0245168>] ? ip6_neigh_lookup+0x59/0x187 [ipv6]
 [<ffffffffa0304b4d>] ipoib_start_xmit+0x1c0/0x54f [ib_ipoib]
 [<ffffffffa030498d>] ? ipoib_path_lookup+0x331/0x331 [ib_ipoib]
 [<ffffffff812c1be3>] dev_hard_start_xmit+0x449/0x60e
 [<ffffffff812c1804>] ? dev_hard_start_xmit+0x6a/0x60e
 [<ffffffff812d95b9>] sch_direct_xmit+0x72/0x201
 [<ffffffff812c2221>] dev_queue_xmit+0x479/0x70e
 [<ffffffff812c1da8>] ? dev_hard_start_xmit+0x60e/0x60e
 [<ffffffff812ca20e>] neigh_connected_output+0xb6/0xd4
 [<ffffffffa023c85b>] ip6_finish_output2+0x304/0x38e [ipv6]
 [<ffffffffa023c777>] ? ip6_finish_output2+0x220/0x38e [ipv6]
 [<ffffffffa0245057>] ? ip6_mtu+0x88/0xa1 [ipv6]
 [<ffffffffa023ca29>] ip6_finish_output+0x144/0x149 [ipv6]
 [<ffffffffa023cb41>] ip6_output+0x113/0x11c [ipv6]
 [<ffffffffa024c51f>] ndisc_send_skb+0x176/0x200 [ipv6]
 [<ffffffffa024c413>] ? ndisc_send_skb+0x6a/0x200 [ipv6]
 [<ffffffff81065350>] ? mark_held_locks+0xcd/0xf5
 [<ffffffffa024ce1a>] __ndisc_send+0x51/0x5d [ipv6]
 [<ffffffffa024e4a0>] ndisc_send_ns+0x75/0x82 [ipv6]
 [<ffffffffa02413ee>] addrconf_dad_timer+0x118/0x136 [ipv6]
 [<ffffffff8103547a>] run_timer_softirq+0x27a/0x38b
 [<ffffffff810353b5>] ? run_timer_softirq+0x1b5/0x38b
 [<ffffffffa02412d6>] ? addrconf_rs_timer+0xf2/0xf2 [ipv6]
 [<ffffffff8102f746>] __do_softirq+0xff/0x1de
 [<ffffffff81362dcc>] call_softirq+0x1c/0x26
 [<ffffffff81003090>] do_softirq+0x38/0x80
 [<ffffffff8102f41f>] irq_exit+0x4e/0x83
 [<ffffffff81019d2e>] smp_apic_timer_interrupt+0x86/0x94
 [<ffffffff8136255c>] apic_timer_interrupt+0x6c/0x80
 <EOI>  [<ffffffff810083ec>] ? mwait_idle+0x13c/0x208
 [<ffffffff810083e3>] ? mwait_idle+0x133/0x208
 [<ffffffff810088d1>] cpu_idle+0x6e/0xab
 [<ffffffff81343a23>] rest_init+0xc7/0xce
 [<ffffffff8134395c>] ? csum_partial_copy_generic+0x16c/0x16c
 [<ffffffff8167fbf3>] start_kernel+0x332/0x33f
 [<ffffffff8167f6f6>] ? kernel_init+0x19d/0x19d
 [<ffffffff8167f2b4>] x86_64_start_reservations+0xb8/0xbd
 [<ffffffff8167f3a6>] x86_64_start_kernel+0xed/0xf4
---[ end trace f71d7a59b646ab87 ]---
