From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 05:37:36 +0100
Message-ID: <1324528656.2621.19.camel@edumazet-laptop>
References: <4EF200BB.7000209@bootc.net>
	  <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <4EF2117F.6000803@bootc.net>
	  <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	 <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 23:12 +0000, Chris Boot a =C3=A9=
crit :
> On 21 Dec 2011, at 21:58, Chris Boot wrote:
>=20
> > On 21/12/2011 20:52, Eric Dumazet wrote:
> >> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 21:28 +0100, Eric Dumazet=
 a =C3=A9crit :
> >>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 20:05 +0000, Chris Boot =
a =C3=A9crit :
> >>>> On 21/12/2011 18:00, Eric Dumazet wrote:
> >>>>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Duma=
zet a =C3=A9crit :
> >>>>>=20
> >>>>>> Good point, thats a different problem then, since 3.1 is not s=
upposed to
> >>>>>> have this bug.
> >>>>>>=20
> >>>>>> It seems rt->rt6i_peer points to invalid memory in your crash.
> >>>>>>=20
> >>>>>> (RBX=3D00000000000001f4)
> >>>>>>=20
> >>>>>> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
> >>>>>> 1f4+a4 ->   CR2=3D0000000000000298
> >>>>>>=20
> >>>>> It would help if you can confirm latest linux tree can reproduc=
e the
> >>>>> bug.
> >>>> Hi Eric,
> >>>>=20
> >>>> I just built a v3.2-rc6-140-gb9e26df with the same config as the=
 Debian
> >>>> 3.1.0 kernel. I can reproduce the bug just as easily with this k=
ernel as
> >>>> with the Debian kernel. Unfortunately I wasn't able to get an en=
tire
> >>>> trace, for some reason it didn't appear to be printed to the ser=
ial port
> >>>> and hung after the (long) list of loaded kernel modules. The cra=
sh
> >>>> happens at the same offset:
> >>>>=20
> >>> Thanks !
> >>>=20
> >>> Oh well, br_netfilter fake_rtable strikes again.
> >>>=20
> >>> I'll cook a patch in a couple of minutes...
> >>>=20
> >> Could you try following patch ?
> >>=20
> >> [snip]
> >=20
> > Eric,
> >=20
> > It looks good! The rsync that caused the crash real quick hasn't do=
ne it at all with the patch applied. I'll keep testing it of course, bu=
t I think that's done it.
>=20
> No, sorry, false hope. The following does look rather different howev=
er:
>=20
> [ 1944.056075] BUG: unable to handle kernel NULL pointer dereference =
at           (null)
> [ 1944.063987] IP: [<          (null)>]           (null)
> [ 1944.069156] PGD 412c75067 PUD 413722067 PMD 0
> [ 1944.073783] Oops: 0010 [#1] SMP
> [ 1944.077201] CPU 0
> [ 1944.079136] Modules linked in: sha1_ssse3 sha1_generic hmac sha256=
_generic dlm configfs ebtable_nat ebtables acpi_cpufreq mperf cpufreq_s=
tats cpufreq_conservative cpufreq_powersave cpufreq_userspace microcode=
 xt_NOTRACK ip_set_hash_net act_police cls_basic cls_flow cls_fw cls_u3=
2 sch_tbf sch_prio sch_hfsc sch_htb sch_ingress sch_sfq xt_realm xt_add=
rtype xt_connlimit ip_set_hash_ip iptable_raw xt_comment xt_recent ipt_=
ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn =
ipt_CLUSTERIP ipt_ah ip6_queue xt_set ip_set nf_nat_tftp nf_nat_snmp_ba=
sic nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_ir=
c nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_conntrack_proto_udplite nf_co=
nntrack_sane nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp=
 nf_conntrack_pptp ts_kmp nf_conntrack_proto_gre nf_conntrack_netlink n=
f_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc nf_connt=
rack_amanda nf_conntrack_h323 nf_conntrack_ftp xt_time xt_TCPMSS xt_TPR=
OXY xt_sctp xt_policy nf_tproxy_core xt_tcpmss xt_pkttype xt_physdev xt=
_owner xt_NFQUEUE xt_NFLOG nfnetlink_log xt_multiport xt_mark xt_mac xt=
_limit ip6t_LOG ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_r=
aw xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp =
ip6table_mangle xt_conntrack xt_connmark xt_CLASSIFY xt_AUDIT ipt_LOG x=
t_tcpudp xt_state iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 n=
f_conntrack iptable_mangle nfnetlink iptable_filter ip_tables ip6table_=
filter ip6_tables x_tables bridge stp bonding w83627ehf hwmon_vid coret=
emp crc32c_intel aesni_intel cryptd aes_x86_64 aes_generic ipmi_powerof=
f ipmi_devintf ipmi_si ipmi_msghandler vhost_net macvtap macvlan tun dr=
bd lru_cache cn loop kvm_intel kvm snd_pcm snd_timer snd soundcore snd_=
page_alloc i2c_i801 i2c_core processor psmouse iTCO_wdt thermal_sys evd=
ev button pcspkr joydev serio_raw iTCO_vendor_support ext4 mbcache jbd2=
 crc16 dm_mod raid1 md_mod usb_storage usbhid uas hid sd_mod crc_t10dif=
 ahci libahci libata ehci_hcd igb scsi_mod dca usbcore e1000e usb_commo=
n [last unloaded: scsi_wait_scan]
> [ 1944.270355]
> [ 1944.271898] Pid: 6833, comm: vhost-6831 Not tainted 3.2.0-rc6+ #2 =
Supermicro X9SCL/X9SCM/X9SCL/X9SCM
> [ 1944.281431] RIP: 0010:[<0000000000000000>]  [<          (null)>]  =
         (null)
> [ 1944.288974] RSP: 0018:ffff88043fc03960  EFLAGS: 00010206
> [ 1944.294422] RAX: ffffffffa0394940 RBX: ffff8804249ab580 RCX: 00000=
00000000000
> [ 1944.301690] RDX: ffff880425f36f70 RSI: ffffffffa03897ac RDI: ffff8=
80425f36f70
> [ 1944.308975] RBP: ffff8803fb9a904e R08: ffff880425f36000 R09: ffff8=
8043fc03970
> [ 1944.316295] R10: ffff8804249ab580 R11: ffff8804249ab580 R12: 00000=
00000000014
> [ 1944.323669] R13: ffff880427373200 R14: ffff880425f36000 R15: ffff8=
8042315c000
> [ 1944.330984] FS:  0000000000000000(0000) GS:ffff88043fc00000(0000) =
knlGS:0000000000000000
> [ 1944.339247] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1944.345153] CR2: 0000000000000000 CR3: 0000000412e64000 CR4: 00000=
000000426e0
> [ 1944.352471] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
> [ 1944.359696] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
> [ 1944.366948] Process vhost-6831 (pid: 6833, threadinfo ffff8804134b=
2000, task ffff880415e93080)
> [ 1944.375836] Stack:
> [ 1944.377893]  ffffffff812a62e1 ffff880425f36f70 ffffffff8168f810 ff=
ff880400000014
> [ 1944.385566]  ffffffffa038e82d ffff8804249ab580 ffffffffa03897ac ff=
ff880427373200
> [ 1944.393283]  0000000000000008 ffff880425f36000 ffff8804249ab580 ff=
ff880425f36000
> [ 1944.400926] Call Trace:
> [ 1944.403442]  <IRQ>
> [ 1944.405668]  [<ffffffff812a62e1>] ? ip_fragment+0x9d/0x62a
> [ 1944.411264]  [<ffffffffa038e82d>] ? br_parse_ip_options+0x19a/0x19=
a [bridge]
> [ 1944.418403]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.424500]  [<ffffffffa038e2cb>] ? br_nf_post_routing+0x17d/0x18f=
 [bridge]
> [ 1944.431661]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1944.437075]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.443168]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.449299]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1944.455055]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.461162]  [<ffffffffa038e2fd>] ? nf_bridge_update_protocol+0x20=
/0x20 [bridge]
> [ 1944.468782]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.474866]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 =
[bridge]
> [ 1944.481904]  [<ffffffffa038e119>] ? nf_bridge_push_encap_header+0x=
1c/0x26 [bridge]
> [ 1944.489657]  [<ffffffffa038e387>] ? br_nf_forward_finish+0x8a/0x95=
 [bridge]
> [ 1944.496793]  [<ffffffffa038e6d0>] ? br_parse_ip_options+0x3d/0x19a=
 [bridge]
> [ 1944.503956]  [<ffffffffa038ea5c>] ? br_nf_forward_ip+0x1c0/0x1d4 [=
bridge]
> [ 1944.510928]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1944.516355]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1944.522803]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1944.529241]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1944.534941]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1944.541337]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1944.548501]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1944.554921]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 =
[bridge]
> [ 1944.561963]  [<ffffffffa03899f2>] ? br_forward+0x16/0x5a [bridge]
> [ 1944.568219]  [<ffffffffa038a51b>] ? br_handle_frame_finish+0x1a1/0=
x20f [bridge]
> [ 1944.575725]  [<ffffffffa038e5f4>] ? br_nf_pre_routing_finish+0x1d0=
/0x1dd [bridge]
> [ 1944.583459]  [<ffffffffa038dfe5>] ? NF_HOOK_THRESH+0x3b/0x55 [brid=
ge]
> [ 1944.589926]  [<ffffffffa038ef4d>] ? br_nf_pre_routing+0x3e8/0x3f5 =
[bridge]
> [ 1944.597036]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1944.602482]  [<ffffffffa0071d51>] ? scsi_request_fn+0x33f/0x404 [s=
csi_mod]
> [ 1944.609613]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1944.616701]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1944.622438]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1944.629566]  [<ffffffffa00714dd>] ? scsi_run_queue+0x212/0x221 [sc=
si_mod]
> [ 1944.636506]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1944.643533]  [<ffffffffa038a360>] ? NF_HOOK.constprop.4+0x3c/0x56 =
[bridge]
> [ 1944.650579]  [<ffffffffa038a73c>] ? br_handle_frame+0x1b3/0x1cb [b=
ridge]
> [ 1944.657440]  [<ffffffffa038a589>] ? br_handle_frame_finish+0x20f/0=
x20f [bridge]
> [ 1944.664924]  [<ffffffff8127ae5d>] ? __netif_receive_skb+0x324/0x41=
f
> [ 1944.671318]  [<ffffffff8127afc4>] ? process_backlog+0x6c/0x123
> [ 1944.677277]  [<ffffffff81194394>] ? blk_done_softirq+0x65/0x74
> [ 1944.683235]  [<ffffffff8127ce3e>] ? net_rx_action+0xa1/0x1af
> [ 1944.688995]  [<ffffffff81036f83>] ? test_tsk_need_resched+0xa/0x13
> [ 1944.695229]  [<ffffffff8104bdc8>] ? __do_softirq+0xb9/0x177
> [ 1944.700887]  [<ffffffff8134122c>] ? call_softirq+0x1c/0x30
> [ 1944.706513]  <EOI>
> [ 1944.708704]  [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
> [ 1944.714116]  [<ffffffff8127d12e>] ? netif_rx_ni+0x1e/0x27
> [ 1944.719617]  [<ffffffffa0264721>] ? tun_get_user+0x39a/0x3c2 [tun]
> [ 1944.725927]  [<ffffffffa0264766>] ? tun_sendmsg+0x1d/0x1f [tun]
> [ 1944.731950]  [<ffffffffa026cb50>] ? handle_tx+0x340/0x3de [vhost_n=
et]
> [ 1944.738506]  [<ffffffffa026a6cb>] ? vhost_worker+0x10b/0x121 [vhos=
t_net]
> [ 1944.745315]  [<ffffffffa026a5c0>] ? vhost_attach_cgroups_work+0x1b=
/0x1b [vhost_net]
> [ 1944.753141]  [<ffffffff8105ee8d>] ? kthread+0x76/0x7e
> [ 1944.758332]  [<ffffffff81341134>] ? kernel_thread_helper+0x4/0x10
> [ 1944.764533]  [<ffffffff8105ee17>] ? kthread_worker_fn+0x139/0x139
> [ 1944.770759]  [<ffffffff81341130>] ? gs_change+0x13/0x13
> [ 1944.776109] Code:  Bad RIP value.
> [ 1944.779528] RIP  [<          (null)>]           (null)
> [ 1944.784777]  RSP <ffff88043fc03960>
> [ 1944.788327] CR2: 0000000000000000
> [ 1944.860298] ---[ end trace 7b7c89d77e0af47a ]---
> [ 1944.864943] Kernel panic - not syncing: Fatal exception in interru=
pt
> [ 1944.871420] Pid: 6833, comm: vhost-6831 Tainted: G      D      3.2=
=2E0-rc6+ #2
> [ 1944.878608] Call Trace:
> [ 1944.881070]  <IRQ>  [<ffffffff81333a17>] ? panic+0x95/0x1a5
> [ 1944.886655]  [<ffffffff8133ae46>] ? oops_end+0xa9/0xb6
> [ 1944.891815]  [<ffffffff8133336e>] ? no_context+0x1ff/0x20e
> [ 1944.897343]  [<ffffffff8133ce59>] ? do_page_fault+0x1a8/0x337
> [ 1944.903091]  [<ffffffff81293e3c>] ? sch_direct_xmit+0x85/0x12f
> [ 1944.908942]  [<ffffffff8133a5b5>] ? page_fault+0x25/0x30
> [ 1944.914291]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.920282]  [<ffffffff812a62e1>] ? ip_fragment+0x9d/0x62a
> [ 1944.925826]  [<ffffffffa038e82d>] ? br_parse_ip_options+0x19a/0x19=
a [bridge]
> [ 1944.932948]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.938939]  [<ffffffffa038e2cb>] ? br_nf_post_routing+0x17d/0x18f=
 [bridge]
> [ 1944.945967]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1944.951296]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.957272]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.963246]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1944.968857]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.974810]  [<ffffffffa038e2fd>] ? nf_bridge_update_protocol+0x20=
/0x20 [bridge]
> [ 1944.982277]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
> [ 1944.988264]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 =
[bridge]
> [ 1944.995213]  [<ffffffffa038e119>] ? nf_bridge_push_encap_header+0x=
1c/0x26 [bridge]
> [ 1945.002868]  [<ffffffffa038e387>] ? br_nf_forward_finish+0x8a/0x95=
 [bridge]
> [ 1945.009908]  [<ffffffffa038e6d0>] ? br_parse_ip_options+0x3d/0x19a=
 [bridge]
> [ 1945.016924]  [<ffffffffa038ea5c>] ? br_nf_forward_ip+0x1c0/0x1d4 [=
bridge]
> [ 1945.023815]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1945.029154]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1945.035466]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1945.041807]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1945.047397]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1945.053711]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1945.060641]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge=
]
> [ 1945.066982]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 =
[bridge]
> [ 1945.073908]  [<ffffffffa03899f2>] ? br_forward+0x16/0x5a [bridge]
> [ 1945.080083]  [<ffffffffa038a51b>] ? br_handle_frame_finish+0x1a1/0=
x20f [bridge]
> [ 1945.087497]  [<ffffffffa038e5f4>] ? br_nf_pre_routing_finish+0x1d0=
/0x1dd [bridge]
> [ 1945.095719]  [<ffffffffa038dfe5>] ? NF_HOOK_THRESH+0x3b/0x55 [brid=
ge]
> [ 1945.102187]  [<ffffffffa038ef4d>] ? br_nf_pre_routing+0x3e8/0x3f5 =
[bridge]
> [ 1945.109095]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
> [ 1945.114455]  [<ffffffffa0071d51>] ? scsi_request_fn+0x33f/0x404 [s=
csi_mod]
> [ 1945.121420]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1945.128399]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
> [ 1945.134054]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1945.141043]  [<ffffffffa00714dd>] ? scsi_run_queue+0x212/0x221 [sc=
si_mod]
> [ 1945.147903]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 =
[bridge]
> [ 1945.154875]  [<ffffffffa038a360>] ? NF_HOOK.constprop.4+0x3c/0x56 =
[bridge]
> [ 1945.161830]  [<ffffffffa038a73c>] ? br_handle_frame+0x1b3/0x1cb [b=
ridge]
> [ 1945.168580]  [<ffffffffa038a589>] ? br_handle_frame_finish+0x20f/0=
x20f [bridge]
> [ 1945.175945]  [<ffffffff8127ae5d>] ? __netif_receive_skb+0x324/0x41=
f
> [ 1945.182243]  [<ffffffff8127afc4>] ? process_backlog+0x6c/0x123
> [ 1945.188118]  [<ffffffff81194394>] ? blk_done_softirq+0x65/0x74
> [ 1945.193958]  [<ffffffff8127ce3e>] ? net_rx_action+0xa1/0x1af
> [ 1945.199638]  [<ffffffff81036f83>] ? test_tsk_need_resched+0xa/0x13
> [ 1945.205887]  [<ffffffff8104bdc8>] ? __do_softirq+0xb9/0x177
> [ 1945.211498]  [<ffffffff8134122c>] ? call_softirq+0x1c/0x30
> [ 1945.217018]  <EOI>  [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
> [ 1945.223149]  [<ffffffff8127d12e>] ? netif_rx_ni+0x1e/0x27
> [ 1945.228602]  [<ffffffffa0264721>] ? tun_get_user+0x39a/0x3c2 [tun]
> [ 1945.234841]  [<ffffffffa0264766>] ? tun_sendmsg+0x1d/0x1f [tun]
> [ 1945.240805]  [<ffffffffa026cb50>] ? handle_tx+0x340/0x3de [vhost_n=
et]
> [ 1945.247269]  [<ffffffffa026a6cb>] ? vhost_worker+0x10b/0x121 [vhos=
t_net]
> [ 1945.254020]  [<ffffffffa026a5c0>] ? vhost_attach_cgroups_work+0x1b=
/0x1b [vhost_net]
> [ 1945.261773]  [<ffffffff8105ee8d>] ? kthread+0x76/0x7e
> [ 1945.266844]  [<ffffffff81341134>] ? kernel_thread_helper+0x4/0x10
> [ 1945.272963]  [<ffffffff8105ee17>] ? kthread_worker_fn+0x139/0x139
> [ 1945.279100]  [<ffffffff81341130>] ? gs_change+0x13/0x13
> [ 1945.284417] Rebooting in 120 seconds..
>=20
> (gdb) list *ip_fragment+0x9d
> 0xffffffff812a62e1 is in ip_fragment (include/net/dst.h:209).
> 204		return dst_metric(dst, RTAX_FEATURES) & feature;
> 205	}
> 206=09
> 207	static inline u32 dst_mtu(const struct dst_entry *dst)
> 208	{
> 209		return dst->ops->mtu(dst);
> 210	}
> 211=09
> 212	/* RTT metrics are stored in milliseconds for user ABI, but used =
as jiffies */

This one is different, its not IPv6 related but IPv4 :

fake_dst_ops lacks a .mtu() field

Bug added in commit 618f9bc74a039da76 (net: Move mtu handling down to
the protocol depended handlers)

Here is an updated patch, thanks again !


 include/net/dst.h         |    1 +
 net/bridge/br_netfilter.c |    8 +++++++-
 net/ipv4/route.c          |    4 ++--
 net/ipv6/ip6_output.c     |    2 +-
 4 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 6faec1a..75766b4 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -53,6 +53,7 @@ struct dst_entry {
 #define DST_NOHASH		0x0008
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
+#define DST_NOPEER		0x0040
=20
 	short			error;
 	short			obsolete;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d6ec372..fa8b8f7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -114,12 +114,18 @@ static struct neighbour *fake_neigh_lookup(const =
struct dst_entry *dst, const vo
 	return NULL;
 }
=20
+static unsigned int fake_mtu(const struct dst_entry *dst)
+{
+	return dst->dev->mtu;
+}
+
 static struct dst_ops fake_dst_ops =3D {
 	.family =3D		AF_INET,
 	.protocol =3D		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =3D		fake_update_pmtu,
 	.cow_metrics =3D		fake_cow_metrics,
 	.neigh_lookup =3D		fake_neigh_lookup,
+	.mtu =3D			fake_mtu,
 };
=20
 /*
@@ -141,7 +147,7 @@ void br_netfilter_rtable_init(struct net_bridge *br=
)
 	rt->dst.dev =3D br->dev;
 	rt->dst.path =3D &rt->dst;
 	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-	rt->dst.flags	=3D DST_NOXFRM;
+	rt->dst.flags	=3D DST_NOXFRM | DST_NOPEER;
 	rt->dst.ops =3D &fake_dst_ops;
 }
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 252c512..a5004f1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1366,7 +1366,7 @@ void __ip_select_ident(struct iphdr *iph, struct =
dst_entry *dst, int more)
 {
 	struct rtable *rt =3D (struct rtable *) dst;
=20
-	if (rt) {
+	if (rt && !(rt->dst.flags & DST_NOPEER)) {
 		if (rt->peer =3D=3D NULL)
 			rt_bind_peer(rt, rt->rt_dst, 1);
=20
@@ -1377,7 +1377,7 @@ void __ip_select_ident(struct iphdr *iph, struct =
dst_entry *dst, int more)
 			iph->id =3D htons(inet_getid(rt->peer, more));
 			return;
 		}
-	} else
+	} else if (!rt)
 		printk(KERN_DEBUG "rt_bind_peer(0) @%p\n",
 		       __builtin_return_address(0));
=20
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84d0bd5..ec56271 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -603,7 +603,7 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struc=
t rt6_info *rt)
 	static atomic_t ipv6_fragmentation_id;
 	int old, new;
=20
-	if (rt) {
+	if (rt && !(rt->dst.flags & DST_NOPEER)) {
 		struct inet_peer *peer;
=20
 		if (!rt->rt6i_peer)
