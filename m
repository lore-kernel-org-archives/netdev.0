From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: niu driver - Transmit timed out - 2.6.29
Date: Fri, 27 Mar 2009 17:42:14 -0700
Message-ID: <49CD7266.1070002@sun.com>
References: <49CB78A4.3020406@krogh.cc> <49CD2996.60502@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:34203 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbZC1ArK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 20:47:10 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n2S0kspi016975
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 17:47:08 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-5.01 64bit (built Feb 19 2009))
 id <0KH600B00XY2NI00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Fri,
 27 Mar 2009 17:46:54 -0700 (PDT)
In-reply-to: <49CD2996.60502@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> Jesper Krogh wrote:
>> Ok. I was just so happy .. (See "Status update on Sun Neptune 10Gbit 
>> driver earlier).
>>
>> But then it "blew up" again:
>>
>> Mar 26 13:25:49 hest kernel: [25335.505049] ------------[ cut here 
>> ]------------
>> Mar 26 13:25:49 hest kernel: [25335.505055] WARNING: at 
>> net/sched/sch_generic.c:226 dev_watchdog+0x1fd/0x210()
>> Mar 26 13:25:49 hest kernel: [25335.505057] Hardware name: Sun Fire 
>> X4600 M2
>> Mar 26 13:25:49 hest kernel: [25335.505059] NETDEV WATCHDOG: eth4 
>> (niu): transmit timed out
>> Mar 26 13:25:49 hest kernel: [25335.505060] Modules linked in: 
>> af_packet ext4 jbd2 crc16 nfsd exportfs autofs4 nfs lockd auth_rpcgss 
>> sunrpc iptable_filter ip_tables x_tables ib_iser rdma_cm ib_cm iw_cm 
>> ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi 
>> scsi_transport_iscsi ipv6 parport_pc lp parport loop sr_mod joydev 
>> psmouse niu usb_storage usbhid i2c_nforce2 libusual hid serio_raw 
>> pcspkr shpchp k8temp pci_hotplug i2c_core button evdev ext3 jbd 
>> mbcache ide_cd_mod cdrom sg sd_mod ata_generic libata mptsas mptspi 
>> mptscsih qla2xxx mptbase scsi_transport_sas scsi_transport_fc 
>> ehci_hcd scsi_transport_spi ohci_hcd e1000 scsi_mod amd74xx usbcore 
>> dm_mirror dm_region_hash dm_log dm_snapshot dm_mod thermal processor 
>> fan thermal_sys fuse
>> Mar 26 13:25:49 hest kernel: [25335.505109] Pid: 0, comm: swapper Not 
>> tainted 2.6.29 #30
>> Mar 26 13:25:49 hest kernel: [25335.505111] Call Trace:
>> Mar 26 13:25:49 hest kernel: [25335.505113]  <IRQ>  
>> [<ffffffff8023d5c2>] warn_slowpath+0xf2/0x130
>> Mar 26 13:25:49 hest kernel: [25335.505124]  [<ffffffff80239d2d>] 
>> task_tick_fair+0x4d/0xd0
>> Mar 26 13:25:49 hest kernel: [25335.505130]  [<ffffffff80355e33>] 
>> cpumask_next_and+0x23/0x40
>> Mar 26 13:25:49 hest kernel: [25335.505132]  [<ffffffff80233f84>] 
>> find_busiest_group+0x204/0x870
>> Mar 26 13:25:49 hest kernel: [25335.505136]  [<ffffffff8035b65e>] 
>> strlcpy+0x4e/0x80
>> Mar 26 13:25:49 hest kernel: [25335.505138]  [<ffffffff8041f11d>] 
>> dev_watchdog+0x1fd/0x210
>> Mar 26 13:25:49 hest kernel: [25335.505141]  [<ffffffff80235ac5>] 
>> run_rebalance_domains+0x3c5/0x530
>> Mar 26 13:25:49 hest kernel: [25335.505143]  [<ffffffff802474bb>] 
>> run_timer_softirq+0x1bb/0x230
>> Mar 26 13:25:49 hest kernel: [25335.505148]  [<ffffffff802574e1>] 
>> sched_clock_cpu+0x131/0x180
>> Mar 26 13:25:49 hest kernel: [25335.505151]  [<ffffffff80242cdb>] 
>> __do_softirq+0x8b/0x150
>> Mar 26 13:25:49 hest kernel: [25335.505155]  [<ffffffff8020d3bc>] 
>> call_softirq+0x1c/0x30
>> Mar 26 13:25:49 hest kernel: [25335.505157]  [<ffffffff8020e505>] 
>> do_softirq+0x35/0x80
>> Mar 26 13:25:49 hest kernel: [25335.505161]  [<ffffffff8021f715>] 
>> smp_apic_timer_interrupt+0x85/0xd0
>> Mar 26 13:25:49 hest kernel: [25335.505163]  [<ffffffff8020cdf3>] 
>> apic_timer_interrupt+0x13/0x20
>> Mar 26 13:25:49 hest kernel: [25335.505164]  <EOI>  
>> [<ffffffff80212dc7>] default_idle+0x27/0x40
>> Mar 26 13:25:49 hest kernel: [25335.505169]  [<ffffffff80212fea>] 
>> c1e_idle+0xba/0x100
>> Mar 26 13:25:49 hest kernel: [25335.505171]  [<ffffffff8020ae80>] 
>> cpu_idle+0x40/0x70
>> Mar 26 13:25:49 hest kernel: [25335.505173] ---[ end trace 
>> e6e4f250dc22390d ]---
>
> There was actually a bit more in the log:
>
> Mar 26 13:25:49 hest kernel: [25335.505176] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:25:49 hest kernel: [25335.587191] niu 0000:84:00.0: niu: 
> eth4: bits (40000000) of register RXDMA_CFIG1 would not cl
> ear, val[c0000000]
> Mar 26 13:25:49 hest last message repeated 4 times
> Mar 26 13:25:58 hest kernel: [25345.504898] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:08 hest kernel: [25355.504758] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:13 hest kernel: [25360.504687] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:18 hest kernel: [25365.504619] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:23 hest kernel: [25370.504549] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:28 hest kernel: [25375.504479] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:33 hest kernel: [25380.504409] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
> Mar 26 13:26:38 hest kernel: [25385.504340] niu 0000:84:00.0: niu: 
> eth4: Transmit timed out, resetting
>
> This is probably the interesting part:
> Mar 26 13:25:49 hest kernel: [25335.587191] niu 0000:84:00.0: niu: 
> eth4: bits (40000000) of register RXDMA_CFIG1 would not clear, 
> val[c0000000]
Jesper,

One of the RX  ring DMAs  is failing to reset. I guess whatever is 
hanging the TX side is affecting the RX side as well. Can you do lspci 
on the function  and its siblings?
Regards
Matheos

>
> Any suggestions?
>
> Is this perhaps just broken hardware.. or a driver issue?  (I had the 
> Sun nxge driver working for around 180 days on the same card.. so I 
> would assume the hardware is ok).
>
> Jesper

