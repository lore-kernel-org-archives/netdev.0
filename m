From: Jay Cliburn <jcliburn@gmail.com>
Subject: atl1 warn_on_slowpath help
Date: Tue, 28 Oct 2008 19:08:46 -0500
Message-ID: <20081028190846.2cc3bd3f@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:23981 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbYJ2AIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 20:08:53 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2901410wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 17:08:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm pretty fuzzy on the mechanics of warn_on_slowpath, so I'd like to
ask for help from more experienced netdev developers.

An atl1 user reports the following warning when receiving a VLAN tagged
packet.

[   27.779463] ------------[ cut here ]------------
[   27.779509] WARNING: at kernel/softirq.c:136 local_bh_enable+0x37/0x81()
[   27.779553] Modules linked in: ppdev lp video output ac battery
acpi_cpufreq cpufreq_ondemand cpufreq_powersave cpufreq_userspace
cpufreq_conservative cpufreq_stats freq_table nfsd auth_rpcgss exportfs
nfs lockd nfs_acl sunrpc ipv6 dm_snapshot dm_mirror dm_log dm_mod 8021q
loop snd_hda_intel snd_pcm snd_seq snd_timer snd_seq_device iTCO_wdt snd
serio_raw i2c_i801 parport_pc evdev rng_core i2c_core pcspkr psmouse
soundcore parport intel_agp agpgart button snd_page_alloc ext3 jbd mbcache
ide_cd_mod cdrom sd_mod ata_generic ata_piix libata piix scsi_mod dock
floppy ide_pci_generic ide_core uhci_hcd ehci_hcd usbcore atl1 mii e1000e
thermal processor fan thermal_sys
[   27.781709] Pid: 0, comm: swapper Not tainted 2.6.27.2 #1
[   27.781753]  [<c01240f2>] warn_on_slowpath+0x40/0x63
[   27.781824]  [<c01195e3>] enqueue_task+0x52/0x5d
[   27.781894]  [<c01196e1>] activate_task+0x16/0x1b
[   27.781963]  [<c011f3ce>] try_to_wake_up+0x13b/0x144
[   27.782033]  [<c01e5f32>] __next_cpu+0x12/0x21
[   27.782102]  [<c011ceb6>] find_busiest_group+0x2fb/0x778
[   27.782172]  [<c01198b9>] __wake_up_common+0x34/0x59
[   27.782242]  [<c012885c>] local_bh_enable+0x37/0x81
[   27.782311]  [<c026fb1f>] sk_filter+0x63/0x6c
[   27.782380]  [<c025fbfb>] sock_queue_rcv_skb+0x26/0xb3
[   27.782450]  [<c02bb741>] packet_rcv_spkt+0xe1/0xf3
[   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
[   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
[   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
[   27.782738]  [<c0155b17>] handle_IRQ_event+0x23/0x51
[   27.782808]  [<c015692e>] handle_edge_irq+0xc2/0x102
[   27.782878]  [<c0105fd5>] do_IRQ+0x4d/0x64
[   27.782947]  [<c010434f>] common_interrupt+0x23/0x28
[   27.783017]  [<c0108df6>] mwait_idle+0x2f/0x3b
[   27.783085]  [<c0102a75>] cpu_idle+0xde/0x101
[   27.783154]  =======================
[   27.783195] ---[ end trace 744634f3da93b46a ]---

I've flailed around trying to find the bug, but haven't been
successful -- primarily because I don't understand the
warn_on_slowpath stuff well enough to know what to look for. Can someone
please take a quick look at drivers/net/atlx/atl1.c around line 2017
and see if there's an obvious error?  I'd really appreciate it.

Thanks,
Jay
