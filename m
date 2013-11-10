From: Chris Boot <bootc@bootc.net>
Subject: Panic on 3.10.18 in nf_conntrack_sip with IPv6
Date: Sun, 10 Nov 2013 10:55:53 +0000
Message-ID: <527F6639.3080503@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

I seem to have a pretty reliably reproducible panic on a fairly plain
3.10.18 kernel when routing IPv6 SIP packets.

The setup is a VM server that routes IPv6 from its external interface to
the VMs running on the host. The host is running Shorewall-generated
ip6tables.

All it takes for this to occur is for my Snom phone running beta IPv6
firmware to attempt to make a call to the Asterisk instance running
inside a VM on the host. This will take the host down and all the VMs
running on it, so I'm a bit reluctant to keep testing this.

Interestingly, I have a 32-bit x86 router running the exact same kernel
with the same modules, and passing the same packets through it doesn't
crash that box. I'll admit the configuration isn't all that similar, but
I thought I should mention it anyway.

Any help in reproducing, diagnosing and fixing this is much appreciated.

Panic below (sorry, I couldn't catch the first few lines):

>  nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_conntrack_sane nf_conntrack_tftp nf_conntrack_sip ts_kmp nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323 nf_conntrack_amanda nf_conntrack_ftp xt_time xt_TPROXY xt_TCPMSS nf_tproxy_core xt_sctp xt_tcpmss xt_policy xt_pkttype xt_physdev xt_owner xt_NFLOG nfnetlink_log xt_NFQUEUE xt_multiport xt_mark xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASSIFY xt_AUDIT iptable_nat nf_nat_ipv4 nf_nat ip6t_REJECT xt_tcpudp xt_state nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack_ipv4 nf_defrag_ipv4 nf
 _conntrack ip6table_raw ip6table_mangle iptable_mangle nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables x_tables bridge stp llc bonding w83627ehf hwmon_vid sha1_ssse3 sha1_generic ipmi
_poweroff ipmi_devintf ipmi_si ipmi_msghandler vhost_net tun macvtap macvlan drbd(O) libcrc32c loop coretemp kvm_intel kvm crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul snd_pcm snd_page_alloc snd_timer glue_helper ablk_helper cryptd iTCO_wdt mperf iTCO_vendor_support snd psmouse soundcore lpc_ich serio_raw i2c_i801 pcspkr joydev evdev mfd_core processor thermal_sys button microcode ext4 crc16 jbd2 mbcache dm_mod raid1 md_mod sg sd_mod crc_t10dif usb_storage hid_generic usbhid hid igb ahci i2c_algo_bit ehci_pci i2c_core libahci ehci_hcd e1000e dca libata usbcore ptp usb_common scsi_mod pps_core
> [  798.824659] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O 3.10.18-0.bootc.1-amd64 #1 bootc 3.10.18-1~bootc1
> [  798.882711] Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9SCM, BIOS 1.1a 09/28/2011
> [  798.913159] task: ffffffff81613400 ti: ffffffff81600000 task.ti: ffffffff81600000
> [  798.940448] RIP: 0010:[<ffffffff812c5b22>]  [<ffffffff812c5b22>] pskb_expand_head+0x2a/0x1e1
> [  798.968806] RSP: 0018:ffff88043fc037c0  EFLAGS: 00010202
> [  798.996088] RAX: 0000000000000002 RBX: ffff88041ad4fb00 RCX: 0000000000000020
> [  799.022024] RDX: 00000000000007ab RSI: 0000000000000000 RDI: ffff88041ad4fb00
> [  799.048233] RBP: 0000000000000000 R08: 0000000000000000 R09: ffff88043fc03938
> [  799.075704] R10: ffffffff8169b3d0 R11: 0000000000000000 R12: ffff8804190f09c0
> [  799.416456] R13: 0000000000000028 R14: 000000000000010d R15: ffffffff81344366
> [  799.442700] FS:  0000000000000000(0000) GS:ffff88043fc00000(0000) knlGS:0000000000000000
> [  799.470328] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  799.494800] CR2: 000000000090f340 CR3: 000000000160c000 CR4: 00000000000407f0
> [  799.519552] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  799.545223] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  799.569433] Stack:
> [  799.588302]  0000000000000030 ffff88041ad4fb00 0000000000000030 ffff8804190f09c0
> [  799.613649]  0000000000000028 000000000000010d ffffffff81344366 ffffffff812c633a
> [  799.636945]  0000000000000028 ffff88041ad4fb00 0000000000000030 ffff8804190f09c0
> [  799.667011] Call Trace:
> [  799.691674]  <IRQ> 
> [  799.693796]  [<ffffffff81344366>] ? ip6_fragment+0x8b5/0x8b5
> [  799.730242]  [<ffffffff812c633a>] ? __pskb_pull_tail+0x68/0x254
> [  799.751162]  [<ffffffff81344366>] ? ip6_fragment+0x8b5/0x8b5
> [  799.772907]  [<ffffffffa056e510>] ? sip_help_udp+0x69/0x95 [nf_conntrack_sip]
> [  799.794260]  [<ffffffffa04744cb>] ? ipv6_helper+0xa7/0xb2 [nf_conntrack_ipv6]
> [  799.815274]  [<ffffffff812f201a>] ? nf_iterate+0x42/0x80
> [  799.835591]  [<ffffffff81341654>] ? __ipv6_neigh_lookup_noref+0x95/0x95
> [  799.857404]  [<ffffffff812f20c1>] ? nf_hook_slow+0x69/0x100
> [  799.878454]  [<ffffffff81344366>] ? ip6_fragment+0x8b5/0x8b5
> [  799.898988]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  799.919895]  [<ffffffff813419ac>] ? nf_hook_thresh.constprop.36+0x2e/0x33
> [  799.941898]  [<ffffffff813419ac>] ? nf_hook_thresh.constprop.36+0x2e/0x33
> [  799.963582]  [<ffffffff81344437>] ? ip6_output+0x7a/0x83
> [  799.983090]  [<ffffffff81343a10>] ? ip6_forward+0x5fd/0x69e
> [  800.001437]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.019612]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.036639]  [<ffffffffa04746ac>] ? __ipv6_conntrack_in+0xc4/0x13f [nf_conntrack_ipv6]
> [  800.057257]  [<ffffffff812f201a>] ? nf_iterate+0x42/0x80
> [  800.075044]  [<ffffffff812f20c1>] ? nf_hook_slow+0x69/0x100
> [  800.092089]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.108860]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.353154]  [<ffffffffa046bc5a>] ? nf_ct_frag6_output+0x9f/0xe8 [nf_defrag_ipv6]
> [  800.371387]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.387677]  [<ffffffffa046b0bc>] ? ipv6_defrag+0xbb/0xcf [nf_defrag_ipv6]
> [  800.406280]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.424998]  [<ffffffff812f201a>] ? nf_iterate+0x42/0x80
> [  800.441318]  [<ffffffff812f20c1>] ? nf_hook_slow+0x69/0x100
> [  800.457694]  [<ffffffff8134446d>] ? pskb_may_pull+0x2d/0x2d
> [  800.474649]  [<ffffffff813445b9>] ? nf_hook_thresh.constprop.13+0x34/0x39
> [  800.495046]  [<ffffffff81344b43>] ? ipv6_rcv+0x2bb/0x30b
> [  800.511896]  [<ffffffff812cea5d>] ? __netif_receive_skb_core+0x437/0x4af
> [  800.532539]  [<ffffffff812ceca1>] ? netif_receive_skb+0x42/0x73
> [  800.551414]  [<ffffffff812cf419>] ? napi_gro_receive+0x35/0x76
> [  800.568152]  [<ffffffffa012e20b>] ? e1000_clean_rx_irq+0x249/0x2cb [e1000e]
> [  800.589151]  [<ffffffffa0131698>] ? e1000e_poll+0x65/0x203 [e1000e]
> [  800.606255]  [<ffffffff810742f4>] ? ktime_get+0x5f/0x6b
> [  800.622019]  [<ffffffff812cf1b8>] ? net_rx_action+0xa7/0x1d9
> [  800.640555]  [<ffffffff8139238c>] ? _raw_spin_unlock_irqrestore+0xc/0xd
> [  800.658116]  [<ffffffff812730de>] ? add_interrupt_randomness+0x39/0x16f
> [  800.677242]  [<ffffffff8104244a>] ? __do_softirq+0xe4/0x1f9
> [  800.696819]  [<ffffffff81398bdc>] ? call_softirq+0x1c/0x30
> [  800.713258]  [<ffffffff8100e9ee>] ? do_softirq+0x3a/0x78
> [  800.731145]  [<ffffffff8104262a>] ? irq_exit+0x3f/0x83
> [  800.747466]  [<ffffffff8100e6ff>] ? do_IRQ+0x81/0x97
> [  800.763133]  [<ffffffff8139262d>] ? common_interrupt+0x6d/0x6d
> [  800.780351]  <EOI> 
> [  800.782499]  [<ffffffff81078ffb>] ? clockevents_program_event+0x9a/0xb6
> [  800.813469]  [<ffffffff812a8110>] ? arch_local_irq_enable+0x4/0x8
> [  800.831484]  [<ffffffff812a84db>] ? cpuidle_enter_state+0x46/0xb1
> [  800.849729]  [<ffffffff812a8615>] ? cpuidle_idle_call+0xcf/0x126
> [  800.869185]  [<ffffffff81013b3b>] ? arch_cpu_idle+0x6/0x1a
> [  800.885493]  [<ffffffff81073255>] ? cpu_startup_entry+0x106/0x169
> [  800.902532]  [<ffffffff816b5d40>] ? start_kernel+0x3d7/0x3e2
> [  800.922455]  [<ffffffff816b577f>] ? repair_env_string+0x57/0x57
> [  800.939302]  [<ffffffff816b559a>] ? x86_64_start_kernel+0xf2/0xfd
> [  800.956528] Code: c3 41 57 41 56 41 55 41 54 55 53 48 89 fb 55 8b 87 dc 00 00 00 89 f5 01 f0 01 c2 85 f6 79 02 0f 0b 8b 87 f4 00 00 00 ff c8 74 02 <0f> 0b 83 c2 3f 89 c8 41 89 cd 80 cc 20 83 e2 c0 f6 87 b2 00 00 
> [  801.015687] RIP  [<ffffffff812c5b22>] pskb_expand_head+0x2a/0x1e1
> [  801.034404]  RSP <ffff88043fc037c0>
> [  801.049813] ---[ end trace a0ea98f51afb8cc0 ]---
> [  801.454124] Kernel panic - not syncing: Fatal exception in interrupt
> [  801.474385] Rebooting in 120 seconds..

The O taint is due to loading LinBIT's drbd module. The crash occurs
even without this, and also in a 3.7.10 kernel that I was using before.

Cheers,
Chris

-- 
Chris Boot
bootc@bootc.net
