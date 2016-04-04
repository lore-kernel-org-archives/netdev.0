From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: Re: System hangs (unable to handle kernel paging request)
Date: Mon, 4 Apr 2016 10:30:26 -0400
Message-ID: <57027A82.6040807@gmail.com>
References: <CAJHPw-M7ZLRXcEHovc4EZL1OiE_SihBte2tE+P8UZenKNya7hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Oleksii Berezhniak <core@irc.lg.ua>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34588 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938AbcDDOa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:30:29 -0400
Received: by mail-qg0-f41.google.com with SMTP id c6so23032323qga.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 07:30:29 -0700 (PDT)
In-Reply-To: <CAJHPw-M7ZLRXcEHovc4EZL1OiE_SihBte2tE+P8UZenKNya7hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016-04-04 03:59 AM, Oleksii Berezhniak wrote:
> Good day.
> 
> We have PPPoE server with CentOS 7 (kernel 3.10.0-327.10.1.el7.dsip.x86_64)
> 
> We applied some PPPoE related patches to this kernel:
> 
> ppp: don't override sk->sk_state in pppoe_flush_dev()
> ppp: fix pppoe_dev deletion condition in pppoe_release()
> pppoe: fix memory corruption in padt work structure
> pppoe: fix reference counting in PPPoE proxy
> 
> Also we built latest version of ixgbe driver from Intel.
> 
> Now we have crashes after approx. one week of uptime:
> 
> [545444.673270] BUG: unable to handle kernel paging request at ffff88a005040200
> [545444.673306] IP: [<ffffffff811c0e95>] kmem_cache_alloc+0x75/0x1d0
> [545444.673335] PGD 0
> [545444.673348] Oops: 0000 [#1] SMP
> [545444.673367] Modules linked in: arc4 ppp_mppe act_police cls_u32
> sch_ingress sch_tbf pptp gre pppoe pppox ppp_generic slhc 8021q garp
> stp mrp llc iptable_nat nf_conn
> track_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat iptable_filter xt_TCPMSS
> iptable_mangle xt_CT nf_conntrack iptable_raw w83793 hwmon_vid
> snd_hda_codec_realtek snd_hda_codec
> _generic snd_hda_intel snd_hda_codec coretemp snd_hda_core iTCO_wdt
> kvm iTCO_vendor_support snd_hwdep snd_seq snd_seq_device ipmi_ssif
> ppdev lpc_ich snd_pcm pcspkr mfd_
> core sg ipmi_si snd_timer snd i2c_i801 ipmi_msghandler ioatdma
> parport_pc parport shpchp soundcore i7core_edac tpm_infineon edac_core
> ip_tables ext4 mbcache jbd2 sd_mod
>  crct10dif_generic crc_t10dif crct10dif_common syscopyarea sysfillrect
> firewire_ohci sysimgblt i2c_algo_bit drm_kms_helper ata_generic
> pata_acpi
> [545444.674383]  ttm firewire_core crc_itu_t serio_raw drm ata_piix
> libata crc32c_intel i2c_core ixgbe(OE) vxlan e1000e ip6_udp_tunnel
> udp_tunnel aacraid dca ptp pps_co
> re
> [545444.674783] CPU: 5 PID: 0 Comm: swapper/5 Tainted: G           OE
> ------------   3.10.0-327.10.1.el7.dsip.x86_64 #1
> [545444.675032] Hardware name: empty empty/S7010, BIOS 'V2.06  ' 03/31/2010
> [545444.675162] task: ffff880139c55c00 ti: ffff880139c84000 task.ti:
> ffff880139c84000
> [545444.675400] RIP: 0010:[<ffffffff811c0e95>]  [<ffffffff811c0e95>]
> kmem_cache_alloc+0x75/0x1d0
> [545444.675641] RSP: 0018:ffff88023fc23ce8  EFLAGS: 00010286
> [545444.675766] RAX: 0000000000000000 RBX: ffff8802302eab00 RCX:
> 000000010eb8edbe
> [545444.676002] RDX: 000000010eb8edbd RSI: 0000000000000020 RDI:
> ffff88013b803700
> [545444.676237] RBP: ffff88023fc23d18 R08: 00000000000175a0 R09:
> ffffffff81517e70
> [545444.676472] R10: 000000000000006b R11: 0000000000000000 R12:
> ffff88a005040200
> [545444.676706] R13: 0000000000000020 R14: ffff88013b803700 R15:
> ffff88013b803700
> [545444.676942] FS:  0000000000000000(0000) GS:ffff88023fc20000(0000)
> knlGS:0000000000000000
> [545444.677180] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [545444.677307] CR2: ffff88a005040200 CR3: 0000000237e63000 CR4:
> 00000000000007e0
> [545444.677543] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [545444.677779] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [545444.678014] Stack:
> [545444.678127]  ffff880237ea2040 ffff8802302eab00 0000000000000280
> 0000000000000280
> [545444.678370]  0000000000000006 ffff880236bb1b60 ffff88023fc23d40
> ffffffff81517e70
> [545444.678614]  0000000000000280 ffff8802302eab00 0000000000000000
> ffff88023fc23d60
> [545444.678857] Call Trace:
> [545444.678973]  <IRQ>
> 
> [545444.678982]
> [545444.679100]  [<ffffffff81517e70>] build_skb+0x30/0x1d0
> [545444.679222]  [<ffffffff8151a973>] __alloc_rx_skb+0x63/0xb0
> [545444.679349]  [<ffffffff8151a9db>] __netdev_alloc_skb+0x1b/0x40
> [545444.679492]  [<ffffffffa0104d8e>] ixgbe_clean_rx_irq+0xee/0xa50 [ixgbe]
> [545444.679624]  [<ffffffff8152862f>] ? __napi_complete+0x1f/0x30
> [545444.679756]  [<ffffffffa0106738>] ixgbe_poll+0x2d8/0x6d0 [ixgbe]
> [545444.679886]  [<ffffffff8152b092>] net_rx_action+0x152/0x240
> [545444.680015]  [<ffffffff81084aef>] __do_softirq+0xef/0x280
> [545444.680144]  [<ffffffff8164735c>] call_softirq+0x1c/0x30
> [545444.680277]  [<ffffffff81016fc5>] do_softirq+0x65/0xa0
> [545444.680402]  [<ffffffff81084e85>] irq_exit+0x115/0x120
> [545444.680529]  [<ffffffff81647ef8>] do_IRQ+0x58/0xf0
> [545444.680660]  [<ffffffff8163d1ad>] common_interrupt+0x6d/0x6d
> [545444.680786]  <EOI>
> [545444.680794]
> [545444.680914]  [<ffffffff81058e96>] ? native_safe_halt+0x6/0x10
> [545444.681041]  [<ffffffff8101dbcf>] default_idle+0x1f/0xc0
> [545444.681168]  [<ffffffff8101e4d6>] arch_cpu_idle+0x26/0x30
> [545444.681297]  [<ffffffff810d62c5>] cpu_startup_entry+0x245/0x290
> [545444.681427]  [<ffffffff810475fa>] start_secondary+0x1ba/0x230
> [545444.681554] Code: ce 00 00 49 8b 50 08 4d 8b 20 49 8b 40 10 4d 85
> e4 0f 84 1f 01 00 00 48 85 c0 0f 84 16 01 00 00 49 63 46 20 48 8d 4a
> 01 4d 8b 06 <49> 8b 1c 04 4c
> 89 e0 65 49 0f c7 08 0f 94 c0 84 c0 74 b9 49 63
> [545444.682056] RIP  [<ffffffff811c0e95>] kmem_cache_alloc+0x75/0x1d0
> [545444.682186]  RSP <ffff88023fc23ce8>
> [545444.682305] CR2: ffff88a005040200
> 
> 
> Every time description and call stack are the same.
> 
> What can be cause of these crashes?
> 
> Thanks.
> 
I am wondering if your kernel has this commit id, 32b3e08fff60494cd1d281a39b51583edfd2b18f.
As this seems to be added to fix issues that look very similar to the trace you are receiving.
Nick
