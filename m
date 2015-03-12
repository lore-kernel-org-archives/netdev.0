From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Thu, 12 Mar 2015 13:08:14 -0700
Message-ID: <5501F22E.4020801@redhat.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20> <CAN_zqfNtYutMCuCuxTLy8bD8gUsPyLF4nb9_=TJx35JPcrs5Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us, sfeldma@gmail.com,
	David Miller <davem@davemloft.net>
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188AbbCLUI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 16:08:28 -0400
In-Reply-To: <CAN_zqfNtYutMCuCuxTLy8bD8gUsPyLF4nb9_=TJx35JPcrs5Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/12/2015 12:20 PM, Madhu Challa wrote:
> Alex,
>
> I see a null pointer deference in fib_trie_unmerge on boot with latest
> net-next and thought it might be related. Pl let me know if you need
> any additional info.
>
> Thanks.
>
> [  131.289254] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000030
> [  131.298052] IP: [<ffffffff8171d75d>] fib_trie_unmerge+0x1d/0x2f0
> [  131.304788] PGD 0
> [  131.307045] Oops: 0000 [#1] SMP
> [  131.310674] Modules linked in: iptable_mangle(+) xt_tcpudp
> ip6table_filter ip6_tables ebtable_nat ebtables ipmi_devintf
> xt_addrtype xt_conntrack ipt_MASQUERADE nf_nat_masquerade_ipv4
> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
> nf_conntrack bridge stp llc dm_thin_pool iptable_filter ip_tables
> x_tables bnep rfcomm bluetooth x86_pkg_temp_thermal intel_powerclamp
> coretemp kvm_intel kvm crc32_pclmul ghash_clmulni_intel aesni_intel
> joydev aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd
> microcode sb_edac edac_core ipmi_si lpc_ich ipmi_msghandler tpm_tis
> wmi acpi_power_meter mac_hid parport_pc ppdev lp parport ixgbe
> hid_generic igb vxlan ip6_udp_tunnel i2c_algo_bit udp_tunnel usbhid
> dca hid ptp mdio pps_core
> [  131.383538] CPU: 8 PID: 242 Comm: kworker/u48:1 Not tainted 4.0.0-rc3+ #2
> [  131.391130] Hardware name: Cisco Systems Inc
> UCSC-C220-M3S/UCSC-C220-M3S, BIOS C220M3.1.5.4f.0.111320130449
> 11/13/2013
> [  131.403090] Workqueue: netns cleanup_net
> [  131.407480] task: ffff88380213cb30 ti: ffff8838027e4000 task.ti:
> ffff8838027e4000
> [  131.415846] RIP: 0010:[<ffffffff8171d75d>]  [<ffffffff8171d75d>]
> fib_trie_unmerge+0x1d/0x2f0
> [  131.425297] RSP: 0018:ffff8838027e7c38  EFLAGS: 00010292
> [  131.431233] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000038
> [  131.439211] RDX: ffff88380cae8138 RSI: 00000000000000ff RDI: 0000000000000000
> [  131.447191] RBP: ffff8838027e7c88 R08: ffff883810ca2f80 R09: 0000000180190008
> [  131.455167] R10: ffffffff81682c43 R11: ffffea00e0432800 R12: ffff88380cae8000
> [  131.463139] R13: ffff881fe27efa40 R14: ffff881fe27efac8 R15: ffff88380cae8008
> [  131.471117] FS:  0000000000000000(0000) GS:ffff88387fc40000(0000)
> knlGS:0000000000000000
> [  131.480163] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  131.486583] CR2: 0000000000000030 CR3: 0000000001c0c000 CR4: 00000000001407e0
> [  131.494562] Stack:
> [  131.496839]  ffff8838027e7c68 ffffffff811c441a ffff883810ca3038
> ffff883810ca2fb0
> [  131.505278]  ffff883810ca3038 0000000000000000 ffff88380cae8000
> ffff881fe27efa40
> [  131.513714]  ffff881fe27efac8 ffff88380cae8008 ffff8838027e7ca8
> ffffffff81717204
> [  131.522147] Call Trace:
> [  131.524911]  [<ffffffff811c441a>] ? kmem_cache_free+0xfa/0x160
> [  131.531455]  [<ffffffff81717204>] fib_unmerge+0x24/0xd0
> [  131.537324]  [<ffffffff8172282f>] fib4_rule_delete+0x1f/0x60
> [  131.543674]  [<ffffffff816bb239>] fib_rules_unregister+0xb9/0xf0
> [  131.550382]  [<ffffffff81722bb5>] fib4_rules_exit+0x15/0x20
> [  131.556609]  [<ffffffff81716643>] ip_fib_net_exit+0x23/0x130
> [  131.562933]  [<ffffffff81716785>] fib_net_exit+0x35/0x40
> [  131.568871]  [<ffffffff8169409d>] ops_exit_list.isra.7+0x4d/0x70
> [  131.575589]  [<ffffffff81694e00>] cleanup_net+0x1b0/0x250
> [  131.581628]  [<ffffffff81087a4d>] process_one_work+0x22d/0x400
> [  131.588145]  [<ffffffff810882ed>] worker_thread+0x2fd/0x550
> [  131.594375]  [<ffffffff81087ff0>] ? rescuer_thread+0x3d0/0x3d0
> [  131.600904]  [<ffffffff8108d603>] kthread+0xe3/0xf0
> [  131.606355]  [<ffffffff8108d520>] ? kthread_stop+0xf0/0xf0
> [  131.612500]  [<ffffffff817a4f58>] ret_from_fork+0x58/0x90
> [  131.618538]  [<ffffffff8108d520>] ? kthread_stop+0xf0/0xf0
> [  131.624675] Code: c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f
> 44 00 00 55 48 8d 4f 38 48 89 f8 48 89 e5 41 57 41 56 41 55 41 54 53
> 48 83 ec 28 <48> 8b 57 30 48 39 ca 48 89 55 c8 0f 84 aa 02 00 00 31 f6
> bf ff
> [  131.647012] RIP  [<ffffffff8171d75d>] fib_trie_unmerge+0x1d/0x2f0
> [  131.653850]  RSP <ffff8838027e7c38>
> [  131.657755] CR2: 0000000000000030
> [  131.661468] ---[ end trace 8db31cc50a0eb505 ]---
> [  131.748516] BUG: unable to handle kernel paging request at ffffffffffffffd8
> [  131.756344] IP: [<ffffffff8108daa0>] kthread_data+0x10/0x20
> [  131.762599] PGD 1c0f067 PUD 1c11067 PMD 0
> [  131.767240] Oops: 0000 [#2] SMP
>

I think I found the root cause for this.  It looks like I should be 
checking to see if the local table even exists before I try to separate 
it from the main trie.  I'll have a patch for this in an hour or so.

- Alex
