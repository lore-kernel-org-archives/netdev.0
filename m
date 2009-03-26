From: Jesper Krogh <jesper@krogh.cc>
Subject: niu driver - Transmit timed out - 2.6.29
Date: Thu, 26 Mar 2009 13:44:20 +0100
Message-ID: <49CB78A4.3020406@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:60075 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175AbZCZMoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 08:44:38 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id B757C3BF441
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 13:44:34 +0100 (CET)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id I1XlfPg0Hv7u for <netdev@vger.kernel.org>;
	Thu, 26 Mar 2009 13:44:22 +0100 (CET)
Received: from [127.0.0.1] (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 396EA3BF3D2
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 13:44:22 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok. I was just so happy .. (See "Status update on Sun Neptune 10Gbit 
driver earlier).

But then it "blew up" again:

Mar 26 13:25:49 hest kernel: [25335.505049] ------------[ cut here 
]------------
Mar 26 13:25:49 hest kernel: [25335.505055] WARNING: at 
net/sched/sch_generic.c:226 dev_watchdog+0x1fd/0x210()
Mar 26 13:25:49 hest kernel: [25335.505057] Hardware name: Sun Fire X4600 M2
Mar 26 13:25:49 hest kernel: [25335.505059] NETDEV WATCHDOG: eth4 (niu): 
transmit timed out
Mar 26 13:25:49 hest kernel: [25335.505060] Modules linked in: af_packet 
ext4 jbd2 crc16 nfsd exportfs autofs4 nfs lockd auth_rpcgss sunrpc 
iptable_filter ip_tables x_tables ib_iser rdma_cm ib_cm iw_cm ib_sa 
ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi 
scsi_transport_iscsi ipv6 parport_pc lp parport loop sr_mod joydev 
psmouse niu usb_storage usbhid i2c_nforce2 libusual hid serio_raw pcspkr 
shpchp k8temp pci_hotplug i2c_core button evdev ext3 jbd mbcache 
ide_cd_mod cdrom sg sd_mod ata_generic libata mptsas mptspi mptscsih 
qla2xxx mptbase scsi_transport_sas scsi_transport_fc ehci_hcd 
scsi_transport_spi ohci_hcd e1000 scsi_mod amd74xx usbcore dm_mirror 
dm_region_hash dm_log dm_snapshot dm_mod thermal processor fan 
thermal_sys fuse
Mar 26 13:25:49 hest kernel: [25335.505109] Pid: 0, comm: swapper Not 
tainted 2.6.29 #30
Mar 26 13:25:49 hest kernel: [25335.505111] Call Trace:
Mar 26 13:25:49 hest kernel: [25335.505113]  <IRQ>  [<ffffffff8023d5c2>] 
warn_slowpath+0xf2/0x130
Mar 26 13:25:49 hest kernel: [25335.505124]  [<ffffffff80239d2d>] 
task_tick_fair+0x4d/0xd0
Mar 26 13:25:49 hest kernel: [25335.505130]  [<ffffffff80355e33>] 
cpumask_next_and+0x23/0x40
Mar 26 13:25:49 hest kernel: [25335.505132]  [<ffffffff80233f84>] 
find_busiest_group+0x204/0x870
Mar 26 13:25:49 hest kernel: [25335.505136]  [<ffffffff8035b65e>] 
strlcpy+0x4e/0x80
Mar 26 13:25:49 hest kernel: [25335.505138]  [<ffffffff8041f11d>] 
dev_watchdog+0x1fd/0x210
Mar 26 13:25:49 hest kernel: [25335.505141]  [<ffffffff80235ac5>] 
run_rebalance_domains+0x3c5/0x530
Mar 26 13:25:49 hest kernel: [25335.505143]  [<ffffffff802474bb>] 
run_timer_softirq+0x1bb/0x230
Mar 26 13:25:49 hest kernel: [25335.505148]  [<ffffffff802574e1>] 
sched_clock_cpu+0x131/0x180
Mar 26 13:25:49 hest kernel: [25335.505151]  [<ffffffff80242cdb>] 
__do_softirq+0x8b/0x150
Mar 26 13:25:49 hest kernel: [25335.505155]  [<ffffffff8020d3bc>] 
call_softirq+0x1c/0x30
Mar 26 13:25:49 hest kernel: [25335.505157]  [<ffffffff8020e505>] 
do_softirq+0x35/0x80
Mar 26 13:25:49 hest kernel: [25335.505161]  [<ffffffff8021f715>] 
smp_apic_timer_interrupt+0x85/0xd0
Mar 26 13:25:49 hest kernel: [25335.505163]  [<ffffffff8020cdf3>] 
apic_timer_interrupt+0x13/0x20
Mar 26 13:25:49 hest kernel: [25335.505164]  <EOI>  [<ffffffff80212dc7>] 
default_idle+0x27/0x40
Mar 26 13:25:49 hest kernel: [25335.505169]  [<ffffffff80212fea>] 
c1e_idle+0xba/0x100
Mar 26 13:25:49 hest kernel: [25335.505171]  [<ffffffff8020ae80>] 
cpu_idle+0x40/0x70
Mar 26 13:25:49 hest kernel: [25335.505173] ---[ end trace 
e6e4f250dc22390d ]---

It is fairly hard to reproduce and pops generally up after af few days 
of production. But I am willing to test patches that would help resolve 
this problem as both the niu-driver and the NFSD on 2.6.29 really 
outperforms the 2.6.26-rc4 + nxge driver I'm currently using.

Hardware: Sun Fire X4600, 32GB of memory

-- 
Jesper
