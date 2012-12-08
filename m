From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: ipgre rss is broken since gro
Date: Sat, 8 Dec 2012 23:31:38 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eric Dumazet" <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4807 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753532Ab2LHXbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 18:31:47 -0500
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Dmitry Kravkov
> Sent: Sunday, December 09, 2012 12:35 AM
> To: Eric Dumazet; netdev@vger.kernel.org
> Subject: ipgre rss is broken since gro
> 
> Please note that at current net-next head behavior is different - I hit null pointer
> dereference, I will try to bisect this behavior too.

Here is the trace for a while:

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0
PGD 0
Oops: 0002 [#1] SMP
Modules linked in: ip_gre gre bnx2x(O) netconsole configfs ip6table_filter ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ipv6 dm_mirror dm_region_hash dm_log dm_mod vhost_net macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support sg coretemp hwmon kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac edac_core i2c_i801 i2c_core lpc_ich mfd_core igb dca ptp pps_core libcrc32c mdio ext3 jbd mbcache sr_mod cdrom sd_mod crc_t10dif aesni_intel ablk_helper cryptd lrw aes_x86_64 x
 ts gf128mul pata_acpi ata_generic ata_piix [last unloaded: bnx2x]
CPU 0
Pid: 0, comm: swapper/0 Tainted: G           O 3.7.0-rc7+ #38 Supermicro X8QB6/X8QB6
RIP: 0010:[<ffffffff8144f35e>]  [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0
RSP: 0018:ffff88047f803c80  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff88046cc557c0 RCX: 0000000000001c04
RDX: 0000000000000900 RSI: 0000000000000000 RDI: ffff88046e37d800
RBP: ffff88047f803cf0 R08: ffff88046cc557e8 R09: ffff88046e37dec0
R10: 00000000000005c4 R11: ffff88046d872ec0 R12: ffff88046e013480
R13: 0000000000000034 R14: 0000000000000590 R15: ffff880466b9dc50
FS:  0000000000000000(0000) GS:ffff88047f800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/0 (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a13420)
Stack:
 ffff880469cc79a8 ffff880866296800 0000000000000482 ffff880469cc7980
 ffff88047f803cd0 ffffffff81461558 ffff880866296800 ffff88046d452080
 ffff88086ce601c8 ffff88046e013480 0000000000000590 ffff88046cc557e8
Call Trace:
 <IRQ>
 [<ffffffff81461558>] ? napi_gro_receive+0x238/0x270
 [<ffffffff814a3ef1>] tcp_gro_receive+0x271/0x2d0
 [<ffffffff814b6aa0>] tcp4_gro_receive+0xb0/0x130
 [<ffffffff814cd02a>] inet_gro_receive+0x16a/0x210
 [<ffffffff81460c79>] dev_gro_receive+0x1c9/0x2d0
 [<ffffffff8146144b>] napi_gro_receive+0x12b/0x270
 [<ffffffffa00daace>] gro_cell_poll+0x2e/0x60 [ip_gre]
 [<ffffffff81460f73>] net_rx_action+0x103/0x280
 [<ffffffff8105dfd7>] __do_softirq+0xd7/0x240
 [<ffffffff815362dc>] call_softirq+0x1c/0x30
 [<ffffffff810164a5>] do_softirq+0x65/0xa0
 [<ffffffff8105ddbd>] irq_exit+0xbd/0xe0
 [<ffffffff81536b66>] do_IRQ+0x66/0xe0
 [<ffffffff8152ca2d>] common_interrupt+0x6d/0x6d
 <EOI>
 [<ffffffff8107e4df>] ? __hrtimer_start_range_ns+0x18f/0x420
 [<ffffffff812bccc1>] ? intel_idle+0xe1/0x150
 [<ffffffff812bcca7>] ? intel_idle+0xc7/0x150
 [<ffffffff8141df79>] cpuidle_enter+0x19/0x20
 [<ffffffff8141df97>] cpuidle_enter_state+0x17/0x50
 [<ffffffff8141e8af>] cpuidle_idle_call+0xcf/0x1a0
 [<ffffffff8101cd2f>] cpu_idle+0xcf/0x120
 [<ffffffff815110e5>] rest_init+0x75/0x80
 [<ffffffff81b05f10>] start_kernel+0x3da/0x3e7
 [<ffffffff81b05954>] ? repair_env_string+0x5b/0x5b
 [<ffffffff81b05356>] x86_64_start_reservations+0x131/0x136
 [<ffffffff81b0545e>] x86_64_start_kernel+0x103/0x112
Code: e8 00 00 00 0f 87 8b 00 00 00 8b 43 68 44 29 e8 3b 43 6c 89 43 68 0f 82 c7 04 00 00 45 89 ed 4c 01 ab e0 00 00 00 49 8b 44 24 08 <48> 89 18 49 89 5c 24 08 0f b6 43 7c a8 10 0f 85 a8 04 00 00 83
RIP  [<ffffffff8144f35e>] skb_gro_receive+0xbe/0x5a0
 RSP <ffff88047f803c80>
CR2: 0000000000000000
---[ end trace e828b50927d09339 ]---
Kernel panic - not syncing: Fatal exception in interrupt
 
> 
