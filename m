From: "Jesper Krogh" <jesper@krogh.cc>
Subject: NIU - transmit timed out (10Gbit Sun Neptune). - 2.6.29
Date: Fri, 17 Apr 2009 10:14:46 +0200 (CEST)
Message-ID: <11897.195.41.66.226.1239956086.squirrel@mail.jabbernet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Matheos.Worku@Sun.COM
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:2576 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754745AbZDQIPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 04:15:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Netdev and Matheos.

This morning I got the transmit timed out on the Neptune card again:
[1714535.390232] WARNING: at net/sched/sch_generic.c:226
dev_watchdog+0x1fd/0x210()
[1714535.390234] Hardware name: Sun Fire X4600 M2
[1714535.390236] NETDEV WATCHDOG: eth4 (niu): transmit timed out
[1714535.390237] Modules linked in: af_packet nfsd exportfs autofs4 nfs
lockd auth_rpcgss sunrpc iptable_filter ip_tables x_tables ib_iser rdma_cm
ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi
scsi_transport_iscsi parport_pc lp parport loop ipv6 psmouse niu serio_raw
i2c_nforce2 shpchp pcspkr k8temp pci_hotplug i2c_core button joydev evdev
ext3 jbd mbcache ide_cd_mod sr_mod cdrom sg sd_mod usb_storage libusual
usbhid hid ata_generic mptsas mptspi libata mptscsih qla2xxx mptbase
scsi_transport_sas scsi_transport_fc ehci_hcd scsi_transport_spi ohci_hcd
e1000 scsi_mod amd74xx usbcore dm_mirror dm_region_hash dm_log dm_snapshot
dm_mod thermal processor fan thermal_sys fuse
[1714535.390285] Pid: 0, comm: swapper Not tainted 2.6.29 #30
[1714535.390287] Call Trace:
[1714535.390289]  <IRQ>  [<ffffffff8023d5c2>] warn_slowpath+0xf2/0x130
[1714535.390299]  [<ffffffff80231247>] __wake_up_sync+0x47/0x90
[1714535.390303]  [<ffffffff802c2fc3>] pollwake+0x43/0x50
[1714535.390308]  [<ffffffff803ffddf>] sock_def_readable+0x5f/0x70
[1714535.390311]  [<ffffffff803fee5f>] sock_queue_rcv_skb+0xcf/0x110
[1714535.390314]  [<ffffffff80453055>] __udp_queue_rcv_skb+0x25/0xe0
[1714535.390319]  [<ffffffff80355e33>] cpumask_next_and+0x23/0x40
[1714535.390322]  [<ffffffff80233f84>] find_busiest_group+0x204/0x870
[1714535.390326]  [<ffffffff8035b65e>] strlcpy+0x4e/0x80
[1714535.390328]  [<ffffffff8041f11d>] dev_watchdog+0x1fd/0x210
[1714535.390330]  [<ffffffff80235ac5>] run_rebalance_domains+0x3c5/0x530
[1714535.390333]  [<ffffffff802474bb>] run_timer_softirq+0x1bb/0x230
[1714535.390338]  [<ffffffff802574e1>] sched_clock_cpu+0x131/0x180
[1714535.390341]  [<ffffffff80242cdb>] __do_softirq+0x8b/0x150
[1714535.390345]  [<ffffffff8020d3bc>] call_softirq+0x1c/0x30
[1714535.390347]  [<ffffffff8020e505>] do_softirq+0x35/0x80
[1714535.390350]  [<ffffffff8021f715>] smp_apic_timer_interrupt+0x85/0xd0
[1714535.390353]  [<ffffffff8020cdf3>] apic_timer_interrupt+0x13/0x20
[1714535.390354]  <EOI>  [<ffffffff80477f70>] unix_poll+0x0/0xb0
[1714535.390360]  [<ffffffff80212dc7>] default_idle+0x27/0x40
[1714535.390362]  [<ffffffff80212fea>] c1e_idle+0xba/0x100
[1714535.390364]  [<ffffffff8020ae80>] cpu_idle+0x40/0x70
[1714535.390366] ---[ end trace f80248e51431b447 ]---


As requested by Matheos I've collected register-dumps every minute in cron
using this script:

#!/bin/bash
echo "################ START ######################"
date
lspci -vvv -xxx -s 84:0
free
date
echo "################ END ######################"

The data from around the timeout is here
http://krogh.cc/~jesper/niu-problem.txt
Reset was done at:
Apr 17 09:00:56 hest kernel: [1714535.390236] NETDEV WATCHDOG: eth4 (niu):
transmit timed out

The log is a bit strage, but it represents the actual behavior of the
system in the period. Much lagging and interactivity very poor. The actual
every minut cron-dump of registers have actually ended in overlapping.

Can this problem be a side effect of the scheduler/ext3 stuff flying
around (I have 2 hung task just before in the log).
http://krogh.cc/~jesper/dmesg-hest-20090417.txt)?

This time.. the problem had a quite different nature. It actually made the
system drop connections (to NFS clients and stuff) over 45 minutes until
it eventually kicked in and reset the card .. which then brought it back
into
operation again. In the period there was basically "no traffic" on the
NIC, which might be why it took so long for the problem to be detected.. ?

Jesper
-- 
Jesper Krogh

