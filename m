From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6: BUG: unable to handle kernel paging request at
 0000000101bca2be
Date: Sat, 28 Jul 2012 21:08:29 +0200
Message-ID: <1343502509.2626.13172.camel@edumazet-glaptop>
References: <50141C95.3030602@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48173 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab2G1TIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 15:08:34 -0400
Received: by wgbdr13 with SMTP id dr13so3701811wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jul 2012 12:08:33 -0700 (PDT)
In-Reply-To: <50141C95.3030602@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-28 at 13:08 -0400, Cristian Rodr=C3=ADguez wrote:
> Hi:
>=20
> Since late Jun, early Jul, both using stable 3.4 and now 3.5 I am
> getting the following crash in the IPv6 code.
>=20
>=20
> <1>[116145.466708] BUG: unable to handle kernel paging request at
> 0000000101bca2be
> <1>[116145.467797] IP: [<ffffffff8145800b>] dst_release+0x1b/0x80
> <4>[116145.468645] PGD 0
> <4>[116145.468964] Oops: 0002 [#1] SMP
> <4>[116145.469479] CPU 6
> <4>[116145.469783] Modules linked in: bluetooth act_police cls_basic
> cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_htb sch_hfsc sch_ingress
> sch_sfq bridge stp xt_statistic xt_CT xt_realm iptable_raw xt_LOG
> xt_connlimit xt_addrtype xt_comment xt_recent ipt_ULOG ipt_REJECT
> ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_CLUSTERIP ipt_ah
> nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip ip6_queue
> nf_nat_pptp nf_nat_proto_gre xt_set ip_set nf_nat_irc nf_nat_h323
> nf_nat_ftp nf_nat_amanda nf_conntrack_tftp nf_conntrack_sane
> nf_conntrack_sip nf_conntrack_proto_udplite nf_conntrack_proto_sctp
> ts_kmp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_amanda
> nf_conntrack_netlink xt_time nf_conntrack_netbios_ns
> nf_conntrack_broadcast xt_TCPMSS nf_conntrack_irc nf_conntrack_h323
> xt_sctp xt_policy ip6t_REJECT nf_conntrack_ipv6 ip6table_raw
> ip6table_mangle nf_conntrack_ftp xt_TPROXY nf_tproxy_core nf_defrag_i=
pv6
> xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_NFLOG
> nfnetlink_log xt_multiport xt_mark xt_mac xt_limit xt_length xt_ipran=
ge
> xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_conntrack xt_connma=
rk
> xt_CLASSIFY xt_AUDIT xt_tcpudp xt_state ip6table_filter iptable_nat
> nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip6_tables nf_conntrack
> iptable_mangle nfnetlink iptable_filter ip_tables x_tables cachefiles
> fscache af_packet edd eeepc_wmi asus_wmi sparse_keymap rfkill
> pci_hotplug acpi_cpufreq mperf coretemp wmi iTCO_wdt crc32c_intel e10=
00e
> mei(C) joydev pcspkr ghash_clmulni_intel iTCO_vendor_support i2c_i801
> xhci_hcd aesni_intel cryptd aes_x86_64 microcode autofs4 usbhid i915
> drm_kms_helper drm ehci_hcd i2c_algo_bit usbcore usb_common video but=
ton
> scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh_rdac scsi_dh fan
> processor thermal thermal_sys megaraid_sas
> <4>[116145.495352]
> <4>[116145.495579] Pid: 0, comm: swapper/6 Tainted: G         C
> 3.4.6-1-default #1 System manufacturer System Product Name/P8B WS
> <4>[116145.497313] RIP: 0010:[<ffffffff8145800b>]  [<ffffffff8145800b=
>]
> dst_release+0x1b/0x80
> <4>[116145.498527] RSP: 0018:ffff88041f383ce0  EFLAGS: 00010202
> <4>[116145.499330] RAX: ffff8803c199e568 RBX: 0000000101bca23e RCX:
> 0000000000000000
> <4>[116145.500407] RDX: 0000000101ba584e RSI: ffff8803c199e568 RDI:
> 0000000101bca23e
> <4>[116145.501484] RBP: 00000000ffffffff R08: 0000000000000025 R09:
> ffff88041f383cb0
> <4>[116145.502560] R10: ffffffffa03f82e0 R11: ffff8803bf369886 R12:
> ffff8803bf369886
> <4>[116145.503636] R13: 0000000000000000 R14: 0000000000000500 R15:
> ffff8803ff0de0c0
> <4>[116145.504714] FS:  0000000000000000(0000) GS:ffff88041f380000(00=
00)
> knlGS:0000000000000000
> <4>[116145.505935] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> <4>[116145.506802] CR2: 0000000101bca2be CR3: 0000000001a0b000 CR4:
> 00000000000407e0
> <4>[116145.507878] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> <4>[116145.508955] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> <4>[116145.510033] Process swapper/6 (pid: 0, threadinfo
> ffff88040a482000, task ffff88040a4800c0)
> <4>[116145.511278] Stack:
> <4>[116145.511582]  0000000002000000 00000000000249f0 ffff8803bf36989=
6
> ffffffff814f088a
> <4>[116145.512754]  ffff8804095fc000 ffff8803bf369896 ffff8803bf36988=
6
> ffffffff81d5fb80
> <4>[116145.513926]  0000000000000500 ffff8804095fc000 000000000000003=
a
> ffffffff814f0dca
> <4>[116145.515100] Call Trace:
> <4>[116145.515482]  [<ffffffff814f088a>] rt6_do_pmtu_disc+0x27a/0x330
> <4>[116145.516369]  [<ffffffff814f0dca>] rt6_pmtu_discovery+0x3a/0x70
> <4>[116145.517252]  [<ffffffff81500423>] icmpv6_rcv+0x3c3/0x4a0
> <4>[116145.563503]  [<ffffffff814e44e7>] ip6_input_finish+0x157/0x380
> <4>[116145.609526]  [<ffffffff81450e93>] __netif_receive_skb+0x493/0x=
510
> <4>[116145.655203]  [<ffffffff81451901>] process_backlog+0xa1/0x170
> <4>[116145.701481]  [<ffffffff81451761>] net_rx_action+0x121/0x220
> <4>[116145.748076]  [<ffffffff810460ad>] __do_softirq+0x9d/0x1f0
> <4>[116145.774285]  [<ffffffff8155be0c>] call_softirq+0x1c/0x30
> <4>[116145.800009]  [<ffffffff81004195>] do_softirq+0x65/0xa0
> <4>[116145.845329]  [<ffffffff8104647e>] irq_exit+0x8e/0xb0
> <4>[116145.890313]  [<ffffffff8155b8da>]
> call_function_single_interrupt+0x6a/0x70
> <4>[116145.935988]  [<ffffffff8131d4a9>] intel_idle+0xe9/0x160
> <4>[116145.981862]  [<ffffffff81418c2e>] cpuidle_idle_call+0x9e/0x280
> <4>[116146.026965]  [<ffffffff8100b53f>] cpu_idle+0x7f/0xd0
> <4>[116146.069060] Code: ff 86 80 00 00 00 48 89 77 58 c3 0f 1f 44 00=
 00
> 48 83 ec 18 48 85 ff 48 89 5c 24 08 48 89 6c 24 10 48 89 fb 74 16 bd =
ff
> ff ff ff <f0> 0f c1 af 80 00 00 00 83 ed 01 78 41 85 ed 74 14 48 8b 5=
c 24
> <1>[116146.129910] RIP  [<ffffffff8145800b>] dst_release+0x1b/0x80
> <4>[116146.172426]  RSP <ffff88041f383ce0>
> <4>[116146.213632] CR2: 0000000101bca2be
>=20
> It apparently appeared in either 3.4.3 or 3.4.4 and persist in 3.5..
>=20
> Will be cool if someone can take a look...

This looks like an error coming from commit
1716a96101c49186bb0b8491922fd3e69030235f
(ipv6: fix problem with expired dst cache)

dst_release() is called with a bogus dst pointer : 0000000101bca23e

rt6_clean_expires() seems to be called where it shouldnt.

Could you try reverting it ?
