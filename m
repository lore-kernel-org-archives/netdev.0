From: Dave Jones <davej@redhat.com>
Subject: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Mon, 30 Aug 2010 21:13:49 -0400
Message-ID: <20100831011348.GA11993@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.kagstrom@netinsight.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756412Ab0HaBOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 21:14:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I installed the Fedora 14 alpha, which is based on 2.6.35.2, and hit
the following trace..



WARNING: at lib/dma-debug.c:811 check_unmap+0x212/0x59b()
Hardware name:  
via-velocity 0000:00:0e.0: DMA-API: device driver frees DMA memory with different size [device address=0x00000000194ba27e] [map size=66 bytes] [unmap size=182 bytes]
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat ipt_LOG xt_limit bluetooth rfkill sunrpc cpufreq_ondemand acpi_cpufreq mperf ip6t_REJECT ip6table_filter nf_conntrack_netbios_ns ip6_tables i2c_viapro 3c59x i2c_core mii via_velocity crc_ccitt ipv6 autofs4 ext2 pata_acpi ata_generic firewire_ohci firewire_core pata_via crc_itu_t [last unloaded: scsi_wait_scan]
Pid: 1712, comm: unix_chkpwd Not tainted 2.6.35.2-9.fc14.i686.PAE #1
Call Trace:
 [<c0441ec5>] warn_slowpath_common+0x6a/0x7f
 [<c05dcc7e>] ? check_unmap+0x212/0x59b
 [<c0441f4d>] warn_slowpath_fmt+0x2b/0x2f
 [<c05dcc7e>] check_unmap+0x212/0x59b
 [<c05dd0b5>] debug_dma_unmap_page+0x5a/0x62
 [<dd22fab4>] pci_unmap_single+0x58/0x63 [via_velocity]
 [<dd23187b>] velocity_tx_srv+0x127/0x1c1 [via_velocity]
 [<dd231ab9>] velocity_poll+0x47/0x89 [via_velocity]
 [<c074b8ff>] net_rx_action+0x9f/0x1b6
 [<c04476e4>] __do_softirq+0xc2/0x179
 [<c04477cf>] do_softirq+0x34/0x56
 [<c0447a4c>] irq_exit+0x3d/0x70
 [<c040a3a3>] do_IRQ+0x7d/0x91
 [<c0408fb5>] common_interrupt+0x35/0x3c
 [<c07e11ed>] ? _raw_spin_unlock_irq+0x27/0x2f
 [<c046ef5e>] ? raw_local_irq_enable+0xa/0x10
 [<c07e11f2>] _raw_spin_unlock_irq+0x2c/0x2f
 [<c043668c>] finish_task_switch+0x59/0xa9
 [<c0436633>] ? finish_task_switch+0x0/0xa9
 [<c07df33f>] schedule+0x51d/0x581
 [<c043e2b5>] __cond_resched+0x1b/0x2b
 [<c07df44d>] _cond_resched+0x1a/0x21
 [<c04d3ac2>] remove_vma+0x25/0x62
 [<c04d4b24>] do_munmap+0x1ed/0x205
 [<c04d5487>] mmap_region+0x70/0x381
 [<c04d59e0>] do_mmap_pgoff+0x248/0x28e
 [<c04d5aea>] sys_mmap_pgoff+0xc4/0xee
 [<c07e141c>] syscall_call+0x7/0xb
---[ end trace a7c3d35b93050b2b ]---
Mapped at:
 [<c05dd335>] debug_dma_map_page+0x44/0xff
 [<dd22ff98>] pci_map_single+0x88/0x94 [via_velocity]
 [<dd230fbc>] velocity_xmit+0xe0/0x2aa [via_velocity]
 [<c074d0ce>] dev_hard_start_xmit+0x1f6/0x2ab
 [<c075de3c>] sch_direct_xmit+0x5c/0x120

I haven't confirmed it yet, but I have a feeling this is due to c79992fddee28bbd31b35ac297e1068d32930179
Doing a build with that backed out now to test.

	Dave

