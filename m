From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: large degradation in ip netns add/exec performance in 3.13?
Date: Thu, 13 Feb 2014 10:38:44 -0800
Message-ID: <1392316724.1752.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52F1461D.8050703@hp.com> <52FAA3A6.9050608@hp.com>
	 <52FAC6D1.50702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:58741 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbaBMSip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 13:38:45 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so10731259pdj.26
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 10:38:45 -0800 (PST)
In-Reply-To: <52FAC6D1.50702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-11 at 16:56 -0800, Rick Jones wrote:
> On 02/11/2014 02:26 PM, Rick Jones wrote:
> > I did have the system lockup once at 16 concurrent streams on the 3.13.0
> > kernel.  Didn't happen the next two times I tried.
> 
> I've had it happen again with a slightly tweaked ("heavier") fake router 
> creation.  I'm guessing the attached soft lockup messages are related 
> and may help point somewhere.
> 
> happy benchmarking,
> 
> rick jones
> 


It doesnt seem to be network related but vfs, you might copy lkml to
your report ...

[  200.884083] BUG: soft lockup - CPU#12 stuck for 23s! [ip:34798]
[  200.911571] Modules linked in: veth ipmi_devintf 8021q garp xt_CHECKSUM iptable_mangle bridge stp llc kvm_intel kvm bonding ipt_REJECT xt_LOG xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter psmouse ip6_tables iptable_filter ip_tables x_tables gpio_ich igb mpt2sas i2c_algo_bit sb_edac scsi_transport_sas ptp ioatdma ipmi_si serio_raw hpwdt edac_core lpc_ich pps_core hpilo be2net dca ipmi_msghandler raid_class mac_hid acpi_power_meter lp parport shpchp hpsa
[  200.911599] CPU: 12 PID: 34798 Comm: ip Not tainted 3.13.0 #1
[  200.911600] Hardware name: HP ProLiant SL230s Gen8/, BIOS P75 08/20/2012
[  200.911602] task: ffff880fe4d3ae60 ti: ffff880fe4c9e000 task.ti: ffff880fe4c9e000
[  200.911603] RIP: 0010:[<ffffffff811ad1e8>]  [<ffffffff811ad1e8>] __lookup_mnt+0x68/0x80
[  200.911609] RSP: 0018:ffff880fe4c9fcd8  EFLAGS: 00000282
[  200.911610] RAX: ffff880fe7151400 RBX: ffffffff8119859b RCX: ffff881ff9464370
[  200.911612] RDX: ffff880fe7151420 RSI: ffff8800b985e9c0 RDI: ffff880fe94cd1a0
[  200.911613] RBP: ffff880fe4c9fce8 R08: 326f6d7500737973 R09: ffff8800b985e9c0
[  200.911614] R10: 003f010100030103 R11: ffffc90000002000 R12: ffff880fe4c9fe00
[  200.911615] R13: ffff880fe244bc08 R14: 0000000000000000 R15: ffff881fe9ce21f0
[  200.911616] FS:  00007fe7048e0700(0000) GS:ffff88203f880000(0000) knlGS:0000000000000000
[  200.911617] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  200.911618] CR2: 000000000043e408 CR3: 0000001fe94bf000 CR4: 00000000000407e0
[  200.911620] Stack:
[  200.911621]  ffff881fe87c62fc ffff880fe7151400 ffff880fe4c9fd18 ffffffff811ad2b0
[  200.911624]  ffff880fe4c9fdb8 ffff880fe4c9ff28 ffff881ff65949c0 ffff880fe4c9ff28
[  200.911626]  ffff880fe4c9fd38 ffffffff8119855e ffff880fe4c9fda8 ffff881ff65949c0
[  200.911629] Call Trace:
[  200.911632]  [<ffffffff811ad2b0>] lookup_mnt+0x30/0x70
[  200.911636]  [<ffffffff8119855e>] follow_mount+0x5e/0x70
[  200.911639]  [<ffffffff81199070>] mountpoint_last+0xc0/0x1d0
[  200.911641]  [<ffffffff8119ad47>] path_mountpoint+0xd7/0x440
[  200.911646]  [<ffffffff810953c9>] ? __rwsem_do_wake+0x119/0x170
[  200.911651]  [<ffffffff81352e17>] ? call_rwsem_wake+0x17/0x30
[  200.911655]  [<ffffffff8117f551>] ? kmem_cache_alloc+0x31/0x160
[  200.911657]  [<ffffffff8119922c>] ? getname_flags+0x5c/0x190
[  200.911659]  [<ffffffff8119b0e4>] filename_mountpoint+0x34/0xc0
[  200.911661]  [<ffffffff8119e65a>] user_path_mountpoint_at+0x4a/0x70
[  200.911664]  [<ffffffff811adcef>] SyS_umount+0x7f/0x3b0
[  200.911665]  [<ffffffff811af548>] ? SyS_mount+0xb8/0xe0
[  200.911669]  [<ffffffff816c3552>] system_call_fastpath+0x16/0x1b
[  200.911670] Code: 48 8b 55 f8 31 c0 48 39 ca 74 2b 48 89 d0 eb 13 0f 1f 00 48 8b 00 48 89 45 f8 48 8b 45 f8 48 39 c8 74 18 48 8b 50 10 48 83 c2 20 <48> 39 d7 75 e3 48 39 70 18 75 dd c9 c3 0f 1f 00 31 c0 c9 c3 0f 
