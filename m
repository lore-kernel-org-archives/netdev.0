From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: skb_under_panic in eth_header (3.0.34)
Date: Thu, 27 Dec 2012 15:16:26 -0800
Message-ID: <1356650186.30414.1710.camel@edumazet-glaptop>
References: <20121227145914.7b318d10@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:50466 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab2L0XQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 18:16:29 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so5572905pbc.18
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 15:16:28 -0800 (PST)
In-Reply-To: <20121227145914.7b318d10@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-27 at 14:59 -0800, Stephen Hemminger wrote:
> Bug report from sysop@prisjakt.nu
> 
> It is a skb_under_panic in eth_header where it trying to make space for
> the Ethernet header?
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=42764
> 
> 
> I got it one more time. Ethernet card is:
> 0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709S Gigabit
> Ethernet (rev 20)
> 
> ethtool -i eth0
> driver: bnx2
> version: 2.1.6
> firmware-version: bc 4.4.14 IPMI 0.1.16
> bus-info: 0000:04:00.0
> 
> ethtool -i eth2
> driver: bnx2
> version: 2.1.6
> firmware-version: bc 4.4.10
> bus-info: 0000:0e:00.0
> 
> Could this be related to an old firmware?
> 
> This machine does a lot of network traffic, because it load data from a
> database every night.
> 
> Kernel version is 3.0.34
> 
> Sorry for not reporting hardware, I thought it was a protocol bug not related
> to a specific card.
> 
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:147!
> invalid opcode: 0000 [#1] SMP 
> CPU 2 
> Modules linked in: af_packet ipmi_devintf ipmi_si ipmi_msghandler ipv6 fuse
> loop sr_mod cdrom mptsas mptscsih mptbase scsi_transport_sas tpm_tis tpm bnx2
> tpm_bios sg i2c_piix4 i2c_core shpchp pci_hotplug button serio_raw linear
> scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc dm_round_robin sd_mod
> crc_t10dif qla2xxx scsi_transport_fc scsi_tgt dm_snapshot dm_multipath scsi_dh
> scsi_mod edd dm_mod ext3 mbcache jbd fan thermal processor thermal_sys hwmon
> [last unloaded: usbcore]
> 
> Pid: 21566, comm: nscd Not tainted 3.0.34-inps #5 IBM BladeCenter LS42
> -[7902CQG]-/Server Blade
> RIP: 0010:[<ffffffff8123fd12>]  [<ffffffff8123fd12>] skb_push+0x75/0x7e
> RSP: 0018:ffff880b956c39d8  EFLAGS: 00010292
> RAX: 0000000000000083 RBX: 0000000000000800 RCX: 0000000000023382
> RDX: 0000000000007878 RSI: 0000000000000046 RDI: ffffffff8152ee9c
> RBP: ffff880b956c39f8 R08: 0000000000000000 R09: 0720072007200720
> R10: ffff880b956c37c8 R11: 0720072007200720 R12: 0000000000000000
> R13: ffff8810231fb718 R14: 0000000000000055 R15: ffff880c25d24000
> FS:  00007fd9a9222950(0000) GS:ffff880c3fc00000(0000) knlGS:00000000e8dafb90
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fd9b403a000 CR3: 0000000c265e8000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process nscd (pid: 21566, threadinfo ffff880b956c2000, task ffff8803e50e4790)
> Stack:
>  0000000000000057 0000000000000080 ffff880c25d24000 ffff880c71806440
>  ffff880b956c3a38 ffffffff8125e0c5 ffff880b956c3a28 0000000000000036
>  ffff8810231fb680 ffff8810231fb718 ffff880b2cc49380 ffff8810231fb710
> Call Trace:
>  [<ffffffff8125e0c5>] eth_header+0x29/0xa8
>  [<ffffffff81251a59>] neigh_resolve_output+0x284/0x2ed
>  [<ffffffff8127575e>] ip_finish_output+0x24c/0x293
>  [<ffffffff81097cac>] ? zone_watermark_ok+0x1a/0x1c
>  [<ffffffff81275846>] ip_output+0xa1/0xa5
>  [<ffffffff81274b92>] ip_local_out+0x24/0x29
>  [<ffffffff81274ba0>] ip_send_skb+0x9/0x4c
>  [<ffffffff8129178b>] udp_send_skb+0x28b/0x2e8
>  [<ffffffff812935cb>] udp_sendmsg+0x501/0x708
>  [<ffffffff810e42dd>] ? poll_freewait+0x8d/0x8d
>  [<ffffffff812740ec>] ? ip_append_page+0x4f4/0x4f4
>  [<ffffffff8109b8f2>] ? __alloc_pages_nodemask+0x731/0x77c
>  [<ffffffff810541ad>] ? sched_clock_local+0x1c/0x80
>  [<ffffffff81299607>] inet_sendmsg+0x83/0x90
>  [<ffffffff81238e93>] sock_sendmsg+0xe3/0x106
>  [<ffffffff810c7c8a>] ? ____cache_alloc_node+0x4c/0x132
>  [<ffffffff810c7b4f>] ? fallback_alloc+0xe1/0x1d0
>  [<ffffffff8126e390>] ? __ip_route_output_key+0x139/0x816
>  [<ffffffff812d24e3>] ? _raw_spin_unlock_bh+0xf/0x11
>  [<ffffffff8123ba9e>] ? release_sock+0xfd/0x106
>  [<ffffffff81239463>] sys_sendto+0xfa/0x123
>  [<ffffffff81239c3d>] ? sys_connect+0x88/0x9c
>  [<ffffffff812d78bb>] system_call_fastpath+0x16/0x1b
> Code: 8b 57 68 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44 24 08 8b bf cc 00 00
> 00 31 c0 48 89 3c 24 48 c7 c7 5a 79 3a 81 e8 df 03 09 00 <0f> 0b eb fe 48 89 c8
> c9 c3 55 89 f1 48 89 e5 48 83 ec 20 83 7f 
> RIP  [<ffffffff8123fd12>] skb_push+0x75/0x7e
>  RSP <ffff880b956c39d8>
> ---[ end trace 7e8c514a1c33a3f0 ]---
> 
> Output of lspci -vvv:

Probably fixed by :

commit e1f165032c8bade3a6bdf546f8faf61fda4dd01c
Author: ramesh.nagappa@gmail.com <ramesh.nagappa@gmail.com>
Date:   Fri Oct 5 19:10:15 2012 +0000

    net: Fix skb_under_panic oops in neigh_resolve_output
    
    The retry loop in neigh_resolve_output() and neigh_connected_output()
    call dev_hard_header() with out reseting the skb to network_header.
    This causes the retry to fail with skb_under_panic. The fix is to
    reset the network_header within the retry loop.
    
    Signed-off-by: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
    Reviewed-by: Shawn Lu <shawn.lu@ericsson.com>
    Reviewed-by: Robert Coulson <robert.coulson@ericsson.com>
    Reviewed-by: Billie Alsup <billie.alsup@ericsson.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
