From: Chris Boot <bootc@bootc.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in ipv6_select_ident
Date: Wed, 21 Dec 2011 23:12:53 +0000
Message-ID: <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
References: <4EF200BB.7000209@bootc.net>  <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4EF2117F.6000803@bootc.net>  <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop> <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
Mime-Version: 1.0 (Apple Message framework v1254)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yuna.grokhost.net ([87.117.228.63]:50134 "EHLO
	yuna.grokhost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab1LUXM6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 18:12:58 -0500
In-Reply-To: <4EF2568C.6040006@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 Dec 2011, at 21:58, Chris Boot wrote:

> On 21/12/2011 20:52, Eric Dumazet wrote:
>> Le mercredi 21 d=E9cembre 2011 =E0 21:28 +0100, Eric Dumazet a =E9cr=
it :
>>> Le mercredi 21 d=E9cembre 2011 =E0 20:05 +0000, Chris Boot a =E9cri=
t :
>>>> On 21/12/2011 18:00, Eric Dumazet wrote:
>>>>> Le mercredi 21 d=E9cembre 2011 =E0 18:36 +0100, Eric Dumazet a =E9=
crit :
>>>>>=20
>>>>>> Good point, thats a different problem then, since 3.1 is not sup=
posed to
>>>>>> have this bug.
>>>>>>=20
>>>>>> It seems rt->rt6i_peer points to invalid memory in your crash.
>>>>>>=20
>>>>>> (RBX=3D00000000000001f4)
>>>>>>=20
>>>>>> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
>>>>>> 1f4+a4 ->   CR2=3D0000000000000298
>>>>>>=20
>>>>> It would help if you can confirm latest linux tree can reproduce =
the
>>>>> bug.
>>>> Hi Eric,
>>>>=20
>>>> I just built a v3.2-rc6-140-gb9e26df with the same config as the D=
ebian
>>>> 3.1.0 kernel. I can reproduce the bug just as easily with this ker=
nel as
>>>> with the Debian kernel. Unfortunately I wasn't able to get an enti=
re
>>>> trace, for some reason it didn't appear to be printed to the seria=
l port
>>>> and hung after the (long) list of loaded kernel modules. The crash
>>>> happens at the same offset:
>>>>=20
>>> Thanks !
>>>=20
>>> Oh well, br_netfilter fake_rtable strikes again.
>>>=20
>>> I'll cook a patch in a couple of minutes...
>>>=20
>> Could you try following patch ?
>>=20
>> [snip]
>=20
> Eric,
>=20
> It looks good! The rsync that caused the crash real quick hasn't done=
 it at all with the patch applied. I'll keep testing it of course, but =
I think that's done it.

No, sorry, false hope. The following does look rather different however=
:

[ 1944.056075] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[ 1944.063987] IP: [<          (null)>]           (null)
[ 1944.069156] PGD 412c75067 PUD 413722067 PMD 0
[ 1944.073783] Oops: 0010 [#1] SMP
[ 1944.077201] CPU 0
[ 1944.079136] Modules linked in: sha1_ssse3 sha1_generic hmac sha256_g=
eneric dlm configfs ebtable_nat ebtables acpi_cpufreq mperf cpufreq_sta=
ts cpufreq_conservative cpufreq_powersave cpufreq_userspace microcode x=
t_NOTRACK ip_set_hash_net act_police cls_basic cls_flow cls_fw cls_u32 =
sch_tbf sch_prio sch_hfsc sch_htb sch_ingress sch_sfq xt_realm xt_addrt=
ype xt_connlimit ip_set_hash_ip iptable_raw xt_comment xt_recent ipt_UL=
OG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ip=
t_CLUSTERIP ipt_ah ip6_queue xt_set ip_set nf_nat_tftp nf_nat_snmp_basi=
c nf_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc =
nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_conntrack_proto_udplite nf_conn=
track_sane nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp n=
f_conntrack_pptp ts_kmp nf_conntrack_proto_gre nf_conntrack_netlink nf_=
conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc nf_conntra=
ck_amanda nf_conntrack_h323 nf_conntrack_ftp xt_time xt_TCPMSS xt_TPROX=
Y xt_sctp xt_policy nf_tproxy_core xt_tcpmss xt_pkttype xt_physdev xt_o=
wner xt_NFQUEUE xt_NFLOG nfnetlink_log xt_multiport xt_mark xt_mac xt_l=
imit ip6t_LOG ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_raw=
 xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp ip=
6table_mangle xt_conntrack xt_connmark xt_CLASSIFY xt_AUDIT ipt_LOG xt_=
tcpudp xt_state iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_=
conntrack iptable_mangle nfnetlink iptable_filter ip_tables ip6table_fi=
lter ip6_tables x_tables bridge stp bonding w83627ehf hwmon_vid coretem=
p crc32c_intel aesni_intel cryptd aes_x86_64 aes_generic ipmi_poweroff =
ipmi_devintf ipmi_si ipmi_msghandler vhost_net macvtap macvlan tun drbd=
 lru_cache cn loop kvm_intel kvm snd_pcm snd_timer snd soundcore snd_pa=
ge_alloc i2c_i801 i2c_core processor psmouse iTCO_wdt thermal_sys evdev=
 button pcspkr joydev serio_raw iTCO_vendor_support ext4 mbcache jbd2 c=
rc16 dm_mod raid1 md_mod usb_storage usbhid uas hid sd_mod crc_t10dif a=
hci libahci libata ehci_hcd igb scsi_mod dca usbcore e1000e usb_common =
[last unloaded: scsi_wait_scan]
[ 1944.270355]
[ 1944.271898] Pid: 6833, comm: vhost-6831 Not tainted 3.2.0-rc6+ #2 Su=
permicro X9SCL/X9SCM/X9SCL/X9SCM
[ 1944.281431] RIP: 0010:[<0000000000000000>]  [<          (null)>]    =
       (null)
[ 1944.288974] RSP: 0018:ffff88043fc03960  EFLAGS: 00010206
[ 1944.294422] RAX: ffffffffa0394940 RBX: ffff8804249ab580 RCX: 0000000=
000000000
[ 1944.301690] RDX: ffff880425f36f70 RSI: ffffffffa03897ac RDI: ffff880=
425f36f70
[ 1944.308975] RBP: ffff8803fb9a904e R08: ffff880425f36000 R09: ffff880=
43fc03970
[ 1944.316295] R10: ffff8804249ab580 R11: ffff8804249ab580 R12: 0000000=
000000014
[ 1944.323669] R13: ffff880427373200 R14: ffff880425f36000 R15: ffff880=
42315c000
[ 1944.330984] FS:  0000000000000000(0000) GS:ffff88043fc00000(0000) kn=
lGS:0000000000000000
[ 1944.339247] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1944.345153] CR2: 0000000000000000 CR3: 0000000412e64000 CR4: 0000000=
0000426e0
[ 1944.352471] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[ 1944.359696] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[ 1944.366948] Process vhost-6831 (pid: 6833, threadinfo ffff8804134b20=
00, task ffff880415e93080)
[ 1944.375836] Stack:
[ 1944.377893]  ffffffff812a62e1 ffff880425f36f70 ffffffff8168f810 ffff=
880400000014
[ 1944.385566]  ffffffffa038e82d ffff8804249ab580 ffffffffa03897ac ffff=
880427373200
[ 1944.393283]  0000000000000008 ffff880425f36000 ffff8804249ab580 ffff=
880425f36000
[ 1944.400926] Call Trace:
[ 1944.403442]  <IRQ>
[ 1944.405668]  [<ffffffff812a62e1>] ? ip_fragment+0x9d/0x62a
[ 1944.411264]  [<ffffffffa038e82d>] ? br_parse_ip_options+0x19a/0x19a =
[bridge]
[ 1944.418403]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.424500]  [<ffffffffa038e2cb>] ? br_nf_post_routing+0x17d/0x18f [=
bridge]
[ 1944.431661]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1944.437075]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.443168]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.449299]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1944.455055]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.461162]  [<ffffffffa038e2fd>] ? nf_bridge_update_protocol+0x20/0=
x20 [bridge]
[ 1944.468782]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.474866]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 [b=
ridge]
[ 1944.481904]  [<ffffffffa038e119>] ? nf_bridge_push_encap_header+0x1c=
/0x26 [bridge]
[ 1944.489657]  [<ffffffffa038e387>] ? br_nf_forward_finish+0x8a/0x95 [=
bridge]
[ 1944.496793]  [<ffffffffa038e6d0>] ? br_parse_ip_options+0x3d/0x19a [=
bridge]
[ 1944.503956]  [<ffffffffa038ea5c>] ? br_nf_forward_ip+0x1c0/0x1d4 [br=
idge]
[ 1944.510928]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1944.516355]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1944.522803]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1944.529241]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1944.534941]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1944.541337]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1944.548501]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1944.554921]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 [b=
ridge]
[ 1944.561963]  [<ffffffffa03899f2>] ? br_forward+0x16/0x5a [bridge]
[ 1944.568219]  [<ffffffffa038a51b>] ? br_handle_frame_finish+0x1a1/0x2=
0f [bridge]
[ 1944.575725]  [<ffffffffa038e5f4>] ? br_nf_pre_routing_finish+0x1d0/0=
x1dd [bridge]
[ 1944.583459]  [<ffffffffa038dfe5>] ? NF_HOOK_THRESH+0x3b/0x55 [bridge=
]
[ 1944.589926]  [<ffffffffa038ef4d>] ? br_nf_pre_routing+0x3e8/0x3f5 [b=
ridge]
[ 1944.597036]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1944.602482]  [<ffffffffa0071d51>] ? scsi_request_fn+0x33f/0x404 [scs=
i_mod]
[ 1944.609613]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1944.616701]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1944.622438]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1944.629566]  [<ffffffffa00714dd>] ? scsi_run_queue+0x212/0x221 [scsi=
_mod]
[ 1944.636506]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1944.643533]  [<ffffffffa038a360>] ? NF_HOOK.constprop.4+0x3c/0x56 [b=
ridge]
[ 1944.650579]  [<ffffffffa038a73c>] ? br_handle_frame+0x1b3/0x1cb [bri=
dge]
[ 1944.657440]  [<ffffffffa038a589>] ? br_handle_frame_finish+0x20f/0x2=
0f [bridge]
[ 1944.664924]  [<ffffffff8127ae5d>] ? __netif_receive_skb+0x324/0x41f
[ 1944.671318]  [<ffffffff8127afc4>] ? process_backlog+0x6c/0x123
[ 1944.677277]  [<ffffffff81194394>] ? blk_done_softirq+0x65/0x74
[ 1944.683235]  [<ffffffff8127ce3e>] ? net_rx_action+0xa1/0x1af
[ 1944.688995]  [<ffffffff81036f83>] ? test_tsk_need_resched+0xa/0x13
[ 1944.695229]  [<ffffffff8104bdc8>] ? __do_softirq+0xb9/0x177
[ 1944.700887]  [<ffffffff8134122c>] ? call_softirq+0x1c/0x30
[ 1944.706513]  <EOI>
[ 1944.708704]  [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
[ 1944.714116]  [<ffffffff8127d12e>] ? netif_rx_ni+0x1e/0x27
[ 1944.719617]  [<ffffffffa0264721>] ? tun_get_user+0x39a/0x3c2 [tun]
[ 1944.725927]  [<ffffffffa0264766>] ? tun_sendmsg+0x1d/0x1f [tun]
[ 1944.731950]  [<ffffffffa026cb50>] ? handle_tx+0x340/0x3de [vhost_net=
]
[ 1944.738506]  [<ffffffffa026a6cb>] ? vhost_worker+0x10b/0x121 [vhost_=
net]
[ 1944.745315]  [<ffffffffa026a5c0>] ? vhost_attach_cgroups_work+0x1b/0=
x1b [vhost_net]
[ 1944.753141]  [<ffffffff8105ee8d>] ? kthread+0x76/0x7e
[ 1944.758332]  [<ffffffff81341134>] ? kernel_thread_helper+0x4/0x10
[ 1944.764533]  [<ffffffff8105ee17>] ? kthread_worker_fn+0x139/0x139
[ 1944.770759]  [<ffffffff81341130>] ? gs_change+0x13/0x13
[ 1944.776109] Code:  Bad RIP value.
[ 1944.779528] RIP  [<          (null)>]           (null)
[ 1944.784777]  RSP <ffff88043fc03960>
[ 1944.788327] CR2: 0000000000000000
[ 1944.860298] ---[ end trace 7b7c89d77e0af47a ]---
[ 1944.864943] Kernel panic - not syncing: Fatal exception in interrupt
[ 1944.871420] Pid: 6833, comm: vhost-6831 Tainted: G      D      3.2.0=
-rc6+ #2
[ 1944.878608] Call Trace:
[ 1944.881070]  <IRQ>  [<ffffffff81333a17>] ? panic+0x95/0x1a5
[ 1944.886655]  [<ffffffff8133ae46>] ? oops_end+0xa9/0xb6
[ 1944.891815]  [<ffffffff8133336e>] ? no_context+0x1ff/0x20e
[ 1944.897343]  [<ffffffff8133ce59>] ? do_page_fault+0x1a8/0x337
[ 1944.903091]  [<ffffffff81293e3c>] ? sch_direct_xmit+0x85/0x12f
[ 1944.908942]  [<ffffffff8133a5b5>] ? page_fault+0x25/0x30
[ 1944.914291]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.920282]  [<ffffffff812a62e1>] ? ip_fragment+0x9d/0x62a
[ 1944.925826]  [<ffffffffa038e82d>] ? br_parse_ip_options+0x19a/0x19a =
[bridge]
[ 1944.932948]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.938939]  [<ffffffffa038e2cb>] ? br_nf_post_routing+0x17d/0x18f [=
bridge]
[ 1944.945967]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1944.951296]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.957272]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.963246]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1944.968857]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.974810]  [<ffffffffa038e2fd>] ? nf_bridge_update_protocol+0x20/0=
x20 [bridge]
[ 1944.982277]  [<ffffffffa03897ac>] ? br_flood+0xfa/0xfa [bridge]
[ 1944.988264]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 [b=
ridge]
[ 1944.995213]  [<ffffffffa038e119>] ? nf_bridge_push_encap_header+0x1c=
/0x26 [bridge]
[ 1945.002868]  [<ffffffffa038e387>] ? br_nf_forward_finish+0x8a/0x95 [=
bridge]
[ 1945.009908]  [<ffffffffa038e6d0>] ? br_parse_ip_options+0x3d/0x19a [=
bridge]
[ 1945.016924]  [<ffffffffa038ea5c>] ? br_nf_forward_ip+0x1c0/0x1d4 [br=
idge]
[ 1945.023815]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1945.029154]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1945.035466]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1945.041807]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1945.047397]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1945.053711]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1945.060641]  [<ffffffffa0389918>] ? __br_deliver+0xa0/0xa0 [bridge]
[ 1945.066982]  [<ffffffffa038985e>] ? NF_HOOK.constprop.8+0x3c/0x56 [b=
ridge]
[ 1945.073908]  [<ffffffffa03899f2>] ? br_forward+0x16/0x5a [bridge]
[ 1945.080083]  [<ffffffffa038a51b>] ? br_handle_frame_finish+0x1a1/0x2=
0f [bridge]
[ 1945.087497]  [<ffffffffa038e5f4>] ? br_nf_pre_routing_finish+0x1d0/0=
x1dd [bridge]
[ 1945.095719]  [<ffffffffa038dfe5>] ? NF_HOOK_THRESH+0x3b/0x55 [bridge=
]
[ 1945.102187]  [<ffffffffa038ef4d>] ? br_nf_pre_routing+0x3e8/0x3f5 [b=
ridge]
[ 1945.109095]  [<ffffffff8129db6d>] ? nf_iterate+0x41/0x77
[ 1945.114455]  [<ffffffffa0071d51>] ? scsi_request_fn+0x33f/0x404 [scs=
i_mod]
[ 1945.121420]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1945.128399]  [<ffffffff8129dc0b>] ? nf_hook_slow+0x68/0x101
[ 1945.134054]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1945.141043]  [<ffffffffa00714dd>] ? scsi_run_queue+0x212/0x221 [scsi=
_mod]
[ 1945.147903]  [<ffffffffa038a37a>] ? NF_HOOK.constprop.4+0x56/0x56 [b=
ridge]
[ 1945.154875]  [<ffffffffa038a360>] ? NF_HOOK.constprop.4+0x3c/0x56 [b=
ridge]
[ 1945.161830]  [<ffffffffa038a73c>] ? br_handle_frame+0x1b3/0x1cb [bri=
dge]
[ 1945.168580]  [<ffffffffa038a589>] ? br_handle_frame_finish+0x20f/0x2=
0f [bridge]
[ 1945.175945]  [<ffffffff8127ae5d>] ? __netif_receive_skb+0x324/0x41f
[ 1945.182243]  [<ffffffff8127afc4>] ? process_backlog+0x6c/0x123
[ 1945.188118]  [<ffffffff81194394>] ? blk_done_softirq+0x65/0x74
[ 1945.193958]  [<ffffffff8127ce3e>] ? net_rx_action+0xa1/0x1af
[ 1945.199638]  [<ffffffff81036f83>] ? test_tsk_need_resched+0xa/0x13
[ 1945.205887]  [<ffffffff8104bdc8>] ? __do_softirq+0xb9/0x177
[ 1945.211498]  [<ffffffff8134122c>] ? call_softirq+0x1c/0x30
[ 1945.217018]  <EOI>  [<ffffffff8100f841>] ? do_softirq+0x3c/0x7b
[ 1945.223149]  [<ffffffff8127d12e>] ? netif_rx_ni+0x1e/0x27
[ 1945.228602]  [<ffffffffa0264721>] ? tun_get_user+0x39a/0x3c2 [tun]
[ 1945.234841]  [<ffffffffa0264766>] ? tun_sendmsg+0x1d/0x1f [tun]
[ 1945.240805]  [<ffffffffa026cb50>] ? handle_tx+0x340/0x3de [vhost_net=
]
[ 1945.247269]  [<ffffffffa026a6cb>] ? vhost_worker+0x10b/0x121 [vhost_=
net]
[ 1945.254020]  [<ffffffffa026a5c0>] ? vhost_attach_cgroups_work+0x1b/0=
x1b [vhost_net]
[ 1945.261773]  [<ffffffff8105ee8d>] ? kthread+0x76/0x7e
[ 1945.266844]  [<ffffffff81341134>] ? kernel_thread_helper+0x4/0x10
[ 1945.272963]  [<ffffffff8105ee17>] ? kthread_worker_fn+0x139/0x139
[ 1945.279100]  [<ffffffff81341130>] ? gs_change+0x13/0x13
[ 1945.284417] Rebooting in 120 seconds..

(gdb) list *ip_fragment+0x9d
0xffffffff812a62e1 is in ip_fragment (include/net/dst.h:209).
204		return dst_metric(dst, RTAX_FEATURES) & feature;
205	}
206=09
207	static inline u32 dst_mtu(const struct dst_entry *dst)
208	{
209		return dst->ops->mtu(dst);
210	}
211=09
212	/* RTT metrics are stored in milliseconds for user ABI, but used as=
 jiffies */
213	static inline unsigned long dst_metric_rtt(const struct dst_entry *=
dst, int metric)

(gdb) list *br_flood+0xfa
0x17ac is in br_dev_queue_push_xmit (net/bridge/br_forward.c:43).
38	{
39		return skb->len - (skb->protocol =3D=3D htons(ETH_P_8021Q) ? VLAN_H=
LEN : 0);
40	}
41=09
42	int br_dev_queue_push_xmit(struct sk_buff *skb)
43	{
44		/* ip_fragment doesn't copy the MAC header */
45		if (nf_bridge_maybe_copy_header(skb) ||
46		    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
47			kfree_skb(skb);

Thanks,
Chris

--=20
Chris Boot
bootc@bootc.net
