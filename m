From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Sat, 25 Aug 2012 10:59:46 +0200
Message-ID: <1345885186.19483.109.camel@edumazet-glaptop>
References: <5038215E.60403@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50633 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849Ab2HYI7w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 04:59:52 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2136028wgb.1
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 01:59:51 -0700 (PDT)
In-Reply-To: <5038215E.60403@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 20:50 -0400, Cristian Rodr=C3=ADguez wrote:
> Hi, the issue I reported with IPV6 few weeks ago seems to be gone, bu=
t
> now I am getting the following crash..
>=20
> > Aug 23 11:51:05 ex6 kernel: [55570.280878] Modules linked in: sg st=
 sr_mod cdrom act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_=
prio sch_htb sch_hfsc sch_ingress sch_sfq bridge stp llc xt_statistic x=
t_CT xt_LOG xt_realm xt_connlimit xt_addrtype iptable_raw xt_comment xt=
_recent ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_=
ECN ipt_CLUSTERIP ipt_ah xt_set ip_set nf_nat_tftp nf_nat_snmp_basic nf=
_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_n=
at_h323 nf_nat_ftp nf_nat_amanda ts_kmp xt_time xt_TCPMSS xt_sctp nf_co=
nntrack_amanda xt_policy nf_conntrack_sane ip6t_REJECT nf_conntrack_tft=
p nf_conntrack_ipv6 nf_conntrack_sip ip6table_raw nf_conntrack_proto_ud=
plite ip6table_mangle nf_conntrack_proto_sctp nf_conntrack_pptp nf_conn=
track_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntra=
ck_broadcast nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_TPR=
OXY nf_tproxy_core nf_defrag_ipv6 xt_tcpmss xt_pkttype xt_physdev xt_ow=
ner xt_
> NFQUEUE xt_NFLOG nfnetlink_
> > Aug 23 11:51:05 ex6 kernel: log xt_multiport xt_mark xt_mac xt_limi=
t xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x=
t_conntrack xt_connmark xt_CLASSIFY xt_AUDIT xt_tcpudp xt_state iptable=
_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_mangl=
e nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables x_table=
s af_packet cachefiles fscache eeepc_wmi asus_wmi sparse_keymap acpi_cp=
ufreq mperf rfkill pci_hotplug e1000e coretemp wmi kvm_intel i2c_i801 k=
vm mei pcspkr joydev ghash_clmulni_intel microcode crc32c_intel edd aes=
ni_intel ablk_helper cryptd aes_x86_64 autofs4 hid_generic usbhid i915 =
xhci_hcd drm_kms_helper drm ehci_hcd i2c_algo_bit usbcore usb_common vi=
deo button scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh_rdac scsi_dh =
fan processor thermal thermal_sys megaraid_sas
> > Aug 23 11:51:05 ex6 kernel: [55570.280987] CPU 6=20
> > Aug 23 11:51:05 ex6 kernel: [55570.280991] Pid: 15597, comm: httpd2=
-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Pr=
oduct Name/P8B WS
> > Aug 23 11:51:05 ex6 kernel: [55570.280993] RIP: 0010:[<ffffffff8156=
2be0>]  [<ffffffff81562be0>] _raw_spin_lock_bh+0x20/0x30
> > Aug 23 11:51:05 ex6 kernel: [55570.281002] RSP: 0018:ffff88018fc79f=
08  EFLAGS: 00000297
> > Aug 23 11:51:05 ex6 kernel: [55570.281004] RAX: 0000000000000014 RB=
X: ffff880407ba4cc0 RCX: 0000000000000001
> > Aug 23 11:51:05 ex6 kernel: [55570.281006] RDX: 0000000000000015 RS=
I: 0000000000000000 RDI: ffff880194f4c090
> > Aug 23 11:51:05 ex6 kernel: [55570.281007] RBP: 0000000000000002 R0=
8: ffff8804089938f0 R09: 0000000000003ced
> > Aug 23 11:51:05 ex6 kernel: [55570.281009] R10: ffff88041e836800 R1=
1: 0000000000000202 R12: ffff880407ba4d08
> > Aug 23 11:51:05 ex6 kernel: [55570.281011] R13: ffff880407ba4cc0 R1=
4: 0000000000000292 R15: 0000293da5c4986a
> > Aug 23 11:51:05 ex6 kernel: [55570.281013] FS:  00007fcd524e4700(00=
00) GS:ffff88041f380000(0000) knlGS:0000000000000000
> > Aug 23 11:51:05 ex6 kernel: [55570.281015] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:05 ex6 kernel: [55570.281017] CR2: 00007fcd51b59000 CR=
3: 0000000208ab4000 CR4: 00000000000407e0
> > Aug 23 11:51:05 ex6 kernel: [55570.281019] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:05 ex6 kernel: [55570.281021] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:05 ex6 kernel: [55570.281023] Process httpd2-event (pi=
d: 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> > Aug 23 11:51:05 ex6 kernel: [55570.281024] Stack:
> > Aug 23 11:51:05 ex6 kernel: [55570.281025]  ffff880194f4c040 ffffff=
ff8145d45d ffff880194f4c040 ffffffff814d120e
> > Aug 23 11:51:05 ex6 kernel: [55570.281029]  ffff880194f5a300 ffff88=
04067d2580 0000000000000001 00007fcd60c8eaa0
> > Aug 23 11:51:05 ex6 kernel: [55570.281033]  0004c7e9679f5fbf ffffff=
ff8145ac14 00007fcd589c02e0 0000000100000000
> > Aug 23 11:51:05 ex6 kernel: [55570.281037] Call Trace:
> > Aug 23 11:51:05 ex6 kernel: [55570.281046]  [<ffffffff8145d45d>] lo=
ck_sock_nested+0xd/0x30
> > Aug 23 11:51:05 ex6 kernel: [55570.281052]  [<ffffffff814d120e>] in=
et_shutdown+0x3e/0x130
> > Aug 23 11:51:05 ex6 kernel: [55570.281058]  [<ffffffff8145ac14>] sy=
s_shutdown+0x74/0x80
> > Aug 23 11:51:05 ex6 kernel: [55570.281066]  [<ffffffff8156a47d>] sy=
stem_call_fastpath+0x1a/0x1f
> > Aug 23 11:51:05 ex6 kernel: [55570.281075]  [<00007fcd5fc42477>] 0x=
7fcd5fc42476
> > Aug 23 11:51:05 ex6 kernel: [55570.281076] Code: 66 39 d0 75 f6 c3 =
0f 1f 44 00 00 53 48 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89=
 c2 c1 ea 10 66 39 c2 74 0e 0f 1f 40 00 <f3> 90 0f b7 03 66 39 d0 75 f6=
 5b c3 90 90 90 90 48 c7 c7 60 74=20
> > Aug 23 11:51:24 ex6 cachefilesd[5919]: Refilling cull table
> > Aug 23 11:51:24 ex6 cachefilesd[5919]: Scan complete
> > Aug 23 11:51:33 ex6 kernel: [55598.253247] BUG: soft lockup - CPU#6=
 stuck for 22s! [httpd2-event:15597]
> > Aug 23 11:51:33 ex6 kernel: [55598.253708] Modules linked in: sg st=
 sr_mod cdrom act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_=
prio sch_htb sch_hfsc sch_ingress sch_sfq bridge stp llc xt_statistic x=
t_CT xt_LOG xt_realm xt_connlimit xt_addrtype iptable_raw xt_comment xt=
_recent ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_=
ECN ipt_CLUSTERIP ipt_ah xt_set ip_set nf_nat_tftp nf_nat_snmp_basic nf=
_conntrack_snmp nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_n=
at_h323 nf_nat_ftp nf_nat_amanda ts_kmp xt_time xt_TCPMSS xt_sctp nf_co=
nntrack_amanda xt_policy nf_conntrack_sane ip6t_REJECT nf_conntrack_tft=
p nf_conntrack_ipv6 nf_conntrack_sip ip6table_raw nf_conntrack_proto_ud=
plite ip6table_mangle nf_conntrack_proto_sctp nf_conntrack_pptp nf_conn=
track_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntra=
ck_broadcast nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_TPR=
OXY nf_tproxy_core nf_defrag_ipv6 xt_tcpmss xt_pkttype xt_physdev xt_ow=
ner xt_
> NFQUEUE xt_NFLOG nfnetlink_
> > Aug 23 11:51:33 ex6 kernel: log xt_multiport xt_mark xt_mac xt_limi=
t xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp x=
t_conntrack xt_connmark xt_CLASSIFY xt_AUDIT xt_tcpudp xt_state iptable=
_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_mangl=
e nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables x_table=
s af_packet cachefiles fscache eeepc_wmi asus_wmi sparse_keymap acpi_cp=
ufreq mperf rfkill pci_hotplug e1000e coretemp wmi kvm_intel i2c_i801 k=
vm mei pcspkr joydev ghash_clmulni_intel microcode crc32c_intel edd aes=
ni_intel ablk_helper cryptd aes_x86_64 autofs4 hid_generic usbhid i915 =
xhci_hcd drm_kms_helper drm ehci_hcd i2c_algo_bit usbcore usb_common vi=
deo button scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh_rdac scsi_dh =
fan processor thermal thermal_sys megaraid_sas
> > Aug 23 11:51:33 ex6 kernel: [55598.253818] CPU 6=20
> > Aug 23 11:51:33 ex6 kernel: [55598.253822] Pid: 15597, comm: httpd2=
-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Pr=
oduct Name/P8B WS
> > Aug 23 11:51:33 ex6 kernel: [55598.253824] RIP: 0010:[<ffffffff8156=
2be5>]  [<ffffffff81562be5>] _raw_spin_lock_bh+0x25/0x30
> > Aug 23 11:51:33 ex6 kernel: [55598.253833] RSP: 0018:ffff88018fc79f=
08  EFLAGS: 00000297
> > Aug 23 11:51:33 ex6 kernel: [55598.253835] RAX: 0000000000000014 RB=
X: ffff880407ba4cc0 RCX: 0000000000000001
> > Aug 23 11:51:33 ex6 kernel: [55598.253837] RDX: 0000000000000015 RS=
I: 0000000000000000 RDI: ffff880194f4c090
> > Aug 23 11:51:33 ex6 kernel: [55598.253839] RBP: 0000000000000002 R0=
8: ffff8804089938f0 R09: 0000000000003ced
> > Aug 23 11:51:33 ex6 kernel: [55598.253841] R10: ffff88041e836800 R1=
1: 0000000000000202 R12: ffff880407ba4d08
> > Aug 23 11:51:33 ex6 kernel: [55598.253842] R13: ffff880407ba4cc0 R1=
4: 0000000000000292 R15: 0000293da5c4986a
> > Aug 23 11:51:33 ex6 kernel: [55598.253845] FS:  00007fcd524e4700(00=
00) GS:ffff88041f380000(0000) knlGS:0000000000000000
> > Aug 23 11:51:33 ex6 kernel: [55598.253847] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:33 ex6 kernel: [55598.253849] CR2: 00007fcd51b59000 CR=
3: 0000000208ab4000 CR4: 00000000000407e0
> > Aug 23 11:51:33 ex6 kernel: [55598.253850] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:33 ex6 kernel: [55598.253852] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:33 ex6 kernel: [55598.253855] Process httpd2-event (pi=
d: 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> > Aug 23 11:51:33 ex6 kernel: [55598.253856] Stack:
> > Aug 23 11:51:33 ex6 kernel: [55598.253857]  ffff880194f4c040 ffffff=
ff8145d45d ffff880194f4c040 ffffffff814d120e
> > Aug 23 11:51:33 ex6 kernel: [55598.253861]  ffff880194f5a300 ffff88=
04067d2580 0000000000000001 00007fcd60c8eaa0
> > Aug 23 11:51:33 ex6 kernel: [55598.253865]  0004c7e9679f5fbf ffffff=
ff8145ac14 00007fcd589c02e0 0000000100000000
> > Aug 23 11:51:33 ex6 kernel: [55598.253868] Call Trace:
> > Aug 23 11:51:33 ex6 kernel: [55598.253877]  [<ffffffff8145d45d>] lo=
ck_sock_nested+0xd/0x30
> > Aug 23 11:51:33 ex6 kernel: [55598.253885]  [<ffffffff814d120e>] in=
et_shutdown+0x3e/0x130
> > Aug 23 11:51:33 ex6 kernel: [55598.253892]  [<ffffffff8145ac14>] sy=
s_shutdown+0x74/0x80
> > Aug 23 11:51:33 ex6 kernel: [55598.253900]  [<ffffffff8156a47d>] sy=
stem_call_fastpath+0x1a/0x1f
> > Aug 23 11:51:33 ex6 kernel: [55598.253909]  [<00007fcd5fc42477>] 0x=
7fcd5fc42476
> > Aug 23 11:51:33 ex6 kernel: [55598.253910] Code: c3 0f 1f 44 00 00 =
53 48 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89 c2 c1 ea 10 66=
 39 c2 74 0e 0f 1f 40 00 f3 90 0f b7 03 <66> 39 d0 75 f6 5b c3 90 90 90=
 90 48 c7 c7 60 74 a5 81 e9 34 d9=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629219] INFO: rcu_sched self-det=
ected stall on CPU { 7}  (t=3D2580171 jiffies)
> > Aug 23 11:51:46 ex6 kernel: [55610.629225] sending NMI to all CPUs:
> > Aug 23 11:51:46 ex6 kernel: [55610.629231] NMI backtrace for cpu 6
> > Aug 23 11:51:46 ex6 kernel: [55610.629234] CPU 6=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629239] Pid: 15597, comm: httpd2=
-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Pr=
oduct Name/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.629242] RIP: 0010:[<ffffffff8156=
2be0>]  [<ffffffff81562be0>] _raw_spin_lock_bh+0x20/0x30
> > Aug 23 11:51:46 ex6 kernel: [55610.629252] RSP: 0018:ffff88018fc79f=
08  EFLAGS: 00000297
> > Aug 23 11:51:46 ex6 kernel: [55610.629255] RAX: 0000000000000014 RB=
X: ffff880194f4c090 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.629257] RDX: 0000000000000015 RS=
I: 0000000000000000 RDI: ffff880194f4c090
> > Aug 23 11:51:46 ex6 kernel: [55610.629260] RBP: 0000000000000002 R0=
8: ffff8804089938f0 R09: 0000000000003ced
> > Aug 23 11:51:46 ex6 kernel: [55610.629262] R10: ffff88041e836800 R1=
1: 0000000000000202 R12: ffff8804067d2580
> > Aug 23 11:51:46 ex6 kernel: [55610.629265] R13: 00000000ffffffea R1=
4: 00007fcd60a664a0 R15: 00007fcd51db52b8
> > Aug 23 11:51:46 ex6 kernel: [55610.629268] FS:  00007fcd524e4700(00=
00) GS:ffff88041f380000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629271] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.629274] CR2: 00007fcd51b59000 CR=
3: 0000000208ab4000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629277] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629279] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.629282] Process httpd2-event (pi=
d: 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> > Aug 23 11:51:46 ex6 kernel: [55610.629284] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.629286]  ffff880194f4c040 ffffff=
ff8145d45d ffff880194f4c040 ffffffff814d120e
> > Aug 23 11:51:46 ex6 kernel: [55610.629292]  ffff880194f5a300 ffff88=
04067d2580 0000000000000001 00007fcd60c8eaa0
> > Aug 23 11:51:46 ex6 kernel: [55610.629297]  0004c7e9679f5fbf ffffff=
ff8145ac14 00007fcd589c02e0 0000000100000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629303] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.629314]  [<ffffffff8145d45d>] lo=
ck_sock_nested+0xd/0x30
> > Aug 23 11:51:46 ex6 kernel: [55610.629323]  [<ffffffff814d120e>] in=
et_shutdown+0x3e/0x130
> > Aug 23 11:51:46 ex6 kernel: [55610.629330]  [<ffffffff8145ac14>] sy=
s_shutdown+0x74/0x80
> > Aug 23 11:51:46 ex6 kernel: [55610.629340]  [<ffffffff8156a47d>] sy=
stem_call_fastpath+0x1a/0x1f
> > Aug 23 11:51:46 ex6 kernel: [55610.629364]  [<00007fcd5fc42477>] 0x=
7fcd5fc42476
> > Aug 23 11:51:46 ex6 kernel: [55610.629366] Code: 66 39 d0 75 f6 c3 =
0f 1f 44 00 00 53 48 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89=
 c2 c1 ea 10 66 39 c2 74 0e 0f 1f 40 00 <f3> 90 0f b7 03 66 39 d0 75 f6=
 5b c3 90 90 90 90 48 c7 c7 60 74=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629413] NMI backtrace for cpu 7
> > Aug 23 11:51:46 ex6 kernel: [55610.629415] CPU 7=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629420] Pid: 0, comm: swapper/7 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.629422] RIP: 0010:[<ffffffff812d=
f109>]  [<ffffffff812df109>] find_next_bit+0x39/0xb0
> > Aug 23 11:51:46 ex6 kernel: [55610.629432] RSP: 0018:ffff88041f3c39=
38  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.629434] RAX: 0000000000000000 RB=
X: ffff88041f3ccfe0 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.629437] RDX: 0000000000000001 RS=
I: 0000000000000200 RDI: 0000000000000200
> > Aug 23 11:51:46 ex6 kernel: [55610.629440] RBP: ffff88041f20d020 R0=
8: ffff88041f3ccfe0 R09: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629442] R10: 0000000000000000 R1=
1: 000000000000c2e2 R12: 000000000000d060
> > Aug 23 11:51:46 ex6 kernel: [55610.629445] R13: 0000000000080000 R1=
4: 00000000000000ff R15: 0000000000000007
> > Aug 23 11:51:46 ex6 kernel: [55610.629448] FS:  0000000000000000(00=
00) GS:ffff88041f3c0000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629451] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.629454] CR2: 00007fcd2c062ac0 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629456] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629459] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.629462] Process swapper/7 (pid: =
0, threadinfo ffff88040abc4000, task ffff88040abc2400)
> > Aug 23 11:51:46 ex6 kernel: [55610.629464] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.629465]  ffffffff8102a4e7 000000=
0081a2cec0 000000000000d020 0000000200000007
> > Aug 23 11:51:46 ex6 kernel: [55610.629471]  0000000000000082 ffff88=
041f3c39b0 0000000000002710 ffffffff81a2ce00
> > Aug 23 11:51:46 ex6 kernel: [55610.629476]  ffff88040abc4000 000000=
0000000007 ffff88040abc4000 ffffffff81a2cec0
> > Aug 23 11:51:46 ex6 kernel: [55610.629482] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.629494]  [<ffffffff8102a4e7>] __=
x2apic_send_IPI_mask+0xb7/0x1a0
> > Aug 23 11:51:46 ex6 kernel: [55610.629503]  [<ffffffff810260ff>] ar=
ch_trigger_all_cpu_backtrace+0x4f/0x90
> > Aug 23 11:51:46 ex6 kernel: [55610.629510]  [<ffffffff810d6d20>] rc=
u_pending+0x210/0x560
> > Aug 23 11:51:46 ex6 kernel: [55610.629519]  [<ffffffff810d78c0>] rc=
u_check_callbacks+0x90/0x110
> > Aug 23 11:51:46 ex6 kernel: [55610.629528]  [<ffffffff8105467f>] up=
date_process_times+0x3f/0x80
> > Aug 23 11:51:46 ex6 kernel: [55610.629536]  [<ffffffff810971fb>] ti=
ck_sched_timer+0x6b/0xe0
> > Aug 23 11:51:46 ex6 kernel: [55610.629544]  [<ffffffff810699a6>] __=
run_hrtimer+0x66/0x1d0
> > Aug 23 11:51:46 ex6 kernel: [55610.629552]  [<ffffffff8106a299>] hr=
timer_interrupt+0xe9/0x210
> > Aug 23 11:51:46 ex6 kernel: [55610.629559]  [<ffffffff81024e93>] sm=
p_apic_timer_interrupt+0x63/0xa0
> > Aug 23 11:51:46 ex6 kernel: [55610.629567]  [<ffffffff8156b0fa>] ap=
ic_timer_interrupt+0x6a/0x70
> > Aug 23 11:51:46 ex6 kernel: [55610.629578]  [<ffffffff814c2c78>] tc=
p_slow_start+0x68/0xa0
> > Aug 23 11:51:46 ex6 kernel: [55610.629585]  [<ffffffff814b6260>] tc=
p_ack+0x560/0x11e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629593]  [<ffffffff814b715d>] tc=
p_rcv_established+0x27d/0x8e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629601]  [<ffffffff814c045e>] tc=
p_v4_do_rcv+0xde/0x340
> > Aug 23 11:51:46 ex6 kernel: [55610.629609]  [<ffffffff814c173b>] tc=
p_v4_rcv+0x59b/0x850
> > Aug 23 11:51:46 ex6 kernel: [55610.629617]  [<ffffffff8149e156>] ip=
_local_deliver_finish+0xd6/0x250
> > Aug 23 11:51:46 ex6 kernel: [55610.629625]  [<ffffffff8146eb5e>] __=
netif_receive_skb+0x67e/0x7e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629633]  [<ffffffff8146ed61>] pr=
ocess_backlog+0xa1/0x180
> > Aug 23 11:51:46 ex6 kernel: [55610.629639]  [<ffffffff8146f830>] ne=
t_rx_action+0x140/0x230
> > Aug 23 11:51:46 ex6 kernel: [55610.629647]  [<ffffffff8104be2e>] __=
do_softirq+0xbe/0x1f0
> > Aug 23 11:51:46 ex6 kernel: [55610.629655]  [<ffffffff8156b7ec>] ca=
ll_softirq+0x1c/0x30
> > Aug 23 11:51:46 ex6 kernel: [55610.629662]  [<ffffffff810045a5>] do=
_softirq+0x75/0xb0
> > Aug 23 11:51:46 ex6 kernel: [55610.629669]  [<ffffffff8104c1e5>] ir=
q_exit+0xa5/0xb0
> > Aug 23 11:51:46 ex6 kernel: [55610.629677]  [<ffffffff8156b2ba>] ca=
ll_function_single_interrupt+0x6a/0x70
> > Aug 23 11:51:46 ex6 kernel: [55610.629686]  [<ffffffff813303cc>] in=
tel_idle+0xec/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.629695]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.629702]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.629710]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.629713] Code: d1 49 89 d1 48 c1 =
e9 06 49 83 e1 c0 4c 8d 04 cf 48 89 f7 48 89 d1 4c 29 cf 83 e1 3f 74 40=
 48 c7 c0 ff ff ff ff 48 d3 e0 49 23 00 <48> 83 ff 3f 76 41 48 85 c0 75=
 52 49 83 c0 08 48 83 ef 40 49 83=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629761] NMI backtrace for cpu 1
> > Aug 23 11:51:46 ex6 kernel: [55610.629765] CPU 1=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629769] Pid: 0, comm: swapper/1 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.629772] RIP: 0010:[<ffffffff8156=
28dd>]  [<ffffffff815628dd>] _raw_spin_lock+0x1d/0x30
> > Aug 23 11:51:46 ex6 kernel: [55610.629781] RSP: 0018:ffff88041f243e=
48  EFLAGS: 00000293
> > Aug 23 11:51:46 ex6 kernel: [55610.629784] RAX: 0000000000000014 RB=
X: ffff880194f4c040 RCX: 0000000100c76001
> > Aug 23 11:51:46 ex6 kernel: [55610.629787] RDX: 0000000000000016 RS=
I: 0000000000000286 RDI: ffff880194f4c090
> > Aug 23 11:51:46 ex6 kernel: [55610.629789] RBP: ffff88040abd4000 R0=
8: ffff88040701a29c R09: 0000000000000028
> > Aug 23 11:51:46 ex6 kernel: [55610.629792] R10: dead000000200200 R1=
1: 0000000000000000 R12: 0000000000000100
> > Aug 23 11:51:46 ex6 kernel: [55610.629794] R13: ffffffff814bd160 R1=
4: ffff880194f4c040 R15: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629798] FS:  0000000000000000(00=
00) GS:ffff88041f240000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629800] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.629803] CR2: 00007fa566135010 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.629806] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.629808] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.629811] Process swapper/1 (pid: =
0, threadinfo ffff88040aba6000, task ffff88040aba4280)
> > Aug 23 11:51:46 ex6 kernel: [55610.629813] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.629815]  ffffffff814bd171 ffff88=
040abd4000 0000000000000100 ffff880194f4c200ug 23 11:51:05 ex6 kernel: =
[55570.280878] Modules linked in: sg st sr_mod cdrom act_police cls_bas=
ic cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_htb sch_hfsc sch_ingres=
s sch_sfq bridge stp llc xt_statistic xt_CT xt_LOG xt_realm xt_connlimi=
t xt_addrtype iptable_raw xt_comment xt_recent ipt_ULOG ipt_REJECT ipt_=
REDIRECT ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_CLUSTERIP ipt_ah xt_set =
ip_set nf_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_na=
t_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda=
 ts_kmp xt_time xt_TCPMSS xt_sctp nf_conntrack_amanda xt_policy nf_conn=
track_sane ip6t_REJECT nf_conntrack_tftp nf_conntrack_ipv6 nf_conntrack=
_sip ip6table_raw nf_conntrack_proto_udplite ip6table_mangle nf_conntra=
ck_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_net=
link nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc nf=
_conntr
> ack_h323 nf_conntrack_ftp xt_TPROXY nf_tproxy_core nf_defrag_ipv6 xt_=
tcpmss xt_pkttype xt_physdev xt_owner xt_NFQUEUE xt_NFLOG nfnetlink_
> Aug 23 11:51:05 ex6 kernel: log xt_multiport xt_mark xt_mac xt_limit
> xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp
> xt_conntrack xt_connmark xt_CLASSIFY xt_AUDIT xt_tcpudp xt_state
> iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack
> iptable_mangle nfnetlink ip6table_filter ip6_tables iptable_filter
> ip_tables x_tables af_packet cachefiles fscache eeepc_wmi asus_wmi
> sparse_keymap acpi_cpufreq mperf rfkill pci_hotplug e1000e coretemp w=
mi
> kvm_intel i2c_i801 kvm mei pcspkr joydev ghash_clmulni_intel microcod=
e
> crc32c_intel edd aesni_intel ablk_helper cryptd aes_x86_64 autofs4
> hid_generic usbhid i915 xhci_hcd drm_kms_helper drm ehci_hcd
> i2c_algo_bit usbcore usb_common video button scsi_dh_hp_sw scsi_dh_al=
ua
> scsi_dh_emc scsi_dh_rdac scsi_dh fan processor thermal thermal_sys
> megaraid_sas
> Aug 23 11:51:05 ex6 kernel: [55570.280987] CPU 6
> Aug 23 11:51:05 ex6 kernel: [55570.280991] Pid: 15597, comm:
> httpd2-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer
> System Product Name/P8B WS
> Aug 23 11:51:05 ex6 kernel: [55570.280993] RIP:
> 0010:[<ffffffff81562be0>]  [<ffffffff81562be0>] _raw_spin_lock_bh+0x2=
0/0x30
> Aug 23 11:51:05 ex6 kernel: [55570.281002] RSP: 0018:ffff88018fc79f08
> EFLAGS: 00000297
> Aug 23 11:51:05 ex6 kernel: [55570.281004] RAX: 0000000000000014 RBX:
> ffff880407ba4cc0 RCX: 0000000000000001
> Aug 23 11:51:05 ex6 kernel: [55570.281006] RDX: 0000000000000015 RSI:
> 0000000000000000 RDI: ffff880194f4c090
> Aug 23 11:51:05 ex6 kernel: [55570.281007] RBP: 0000000000000002 R08:
> ffff8804089938f0 R09: 0000000000003ced
> Aug 23 11:51:05 ex6 kernel: [55570.281009] R10: ffff88041e836800 R11:
> 0000000000000202 R12: ffff880407ba4d08
> Aug 23 11:51:05 ex6 kernel: [55570.281011] R13: ffff880407ba4cc0 R14:
> 0000000000000292 R15: 0000293da5c4986a
> Aug 23 11:51:05 ex6 kernel: [55570.281013] FS:  00007fcd524e4700(0000=
)
> GS:ffff88041f380000(0000) knlGS:0000000000000000
> Aug 23 11:51:05 ex6 kernel: [55570.281015] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:05 ex6 kernel: [55570.281017] CR2: 00007fcd51b59000 CR3:
> 0000000208ab4000 CR4: 00000000000407e0
> Aug 23 11:51:05 ex6 kernel: [55570.281019] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:05 ex6 kernel: [55570.281021] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:05 ex6 kernel: [55570.281023] Process httpd2-event (pid:
> 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> Aug 23 11:51:05 ex6 kernel: [55570.281024] Stack:
> Aug 23 11:51:05 ex6 kernel: [55570.281025]  ffff880194f4c040
> ffffffff8145d45d ffff880194f4c040 ffffffff814d120e
> Aug 23 11:51:05 ex6 kernel: [55570.281029]  ffff880194f5a300
> ffff8804067d2580 0000000000000001 00007fcd60c8eaa0
> Aug 23 11:51:05 ex6 kernel: [55570.281033]  0004c7e9679f5fbf
> ffffffff8145ac14 00007fcd589c02e0 0000000100000000
> Aug 23 11:51:05 ex6 kernel: [55570.281037] Call Trace:
> Aug 23 11:51:05 ex6 kernel: [55570.281046]  [<ffffffff8145d45d>]
> lock_sock_nested+0xd/0x30
> Aug 23 11:51:05 ex6 kernel: [55570.281052]  [<ffffffff814d120e>]
> inet_shutdown+0x3e/0x130
> Aug 23 11:51:05 ex6 kernel: [55570.281058]  [<ffffffff8145ac14>]
> sys_shutdown+0x74/0x80
> Aug 23 11:51:05 ex6 kernel: [55570.281066]  [<ffffffff8156a47d>]
> system_call_fastpath+0x1a/0x1f
> Aug 23 11:51:05 ex6 kernel: [55570.281075]  [<00007fcd5fc42477>]
> 0x7fcd5fc42476
> Aug 23 11:51:05 ex6 kernel: [55570.281076] Code: 66 39 d0 75 f6 c3 0f=
 1f
> 44 00 00 53 48 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89 c2 =
c1
> ea 10 66 39 c2 74 0e 0f 1f 40 00 <f3> 90 0f b7 03 66 39 d0 75 f6 5b c=
3
> 90 90 90 90 48 c7 c7 60 74
> Aug 23 11:51:24 ex6 cachefilesd[5919]: Refilling cull table
> Aug 23 11:51:24 ex6 cachefilesd[5919]: Scan complete
> Aug 23 11:51:33 ex6 kernel: [55598.253247] BUG: soft lockup - CPU#6
> stuck for 22s! [httpd2-event:15597]
> Aug 23 11:51:33 ex6 kernel: [55598.253708] Modules linked in: sg st
> sr_mod cdrom act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf
> sch_prio sch_htb sch_hfsc sch_ingress sch_sfq bridge stp llc
> xt_statistic xt_CT xt_LOG xt_realm xt_connlimit xt_addrtype iptable_r=
aw
> xt_comment xt_recent ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NETMAP
> ipt_MASQUERADE ipt_ECN ipt_CLUSTERIP ipt_ah xt_set ip_set nf_nat_tftp
> nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp
> nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_k=
mp
> xt_time xt_TCPMSS xt_sctp nf_conntrack_amanda xt_policy
> nf_conntrack_sane ip6t_REJECT nf_conntrack_tftp nf_conntrack_ipv6
> nf_conntrack_sip ip6table_raw nf_conntrack_proto_udplite ip6table_man=
gle
> nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre
> nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_broadcast
> nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_TPROXY
> nf_tproxy_core nf_defrag_ipv6 xt_tcpmss xt_pkttype xt_physdev xt_owne=
r
> xt_NFQUEUE xt_NFLOG nfnetlink_
> Aug 23 11:51:33 ex6 kernel: log xt_multiport xt_mark xt_mac xt_limit
> xt_length xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp
> xt_conntrack xt_connmark xt_CLASSIFY xt_AUDIT xt_tcpudp xt_state
> iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack
> iptable_mangle nfnetlink ip6table_filter ip6_tables iptable_filter
> ip_tables x_tables af_packet cachefiles fscache eeepc_wmi asus_wmi
> sparse_keymap acpi_cpufreq mperf rfkill pci_hotplug e1000e coretemp w=
mi
> kvm_intel i2c_i801 kvm mei pcspkr joydev ghash_clmulni_intel microcod=
e
> crc32c_intel edd aesni_intel ablk_helper cryptd aes_x86_64 autofs4
> hid_generic usbhid i915 xhci_hcd drm_kms_helper drm ehci_hcd
> i2c_algo_bit usbcore usb_common video button scsi_dh_hp_sw scsi_dh_al=
ua
> scsi_dh_emc scsi_dh_rdac scsi_dh fan processor thermal thermal_sys
> megaraid_sas
> Aug 23 11:51:33 ex6 kernel: [55598.253818] CPU 6
> Aug 23 11:51:33 ex6 kernel: [55598.253822] Pid: 15597, comm:
> httpd2-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer
> System Product Name/P8B WS
> Aug 23 11:51:33 ex6 kernel: [55598.253824] RIP:
> 0010:[<ffffffff81562be5>]  [<ffffffff81562be5>] _raw_spin_lock_bh+0x2=
5/0x30
> Aug 23 11:51:33 ex6 kernel: [55598.253833] RSP: 0018:ffff88018fc79f08
> EFLAGS: 00000297
> Aug 23 11:51:33 ex6 kernel: [55598.253835] RAX: 0000000000000014 RBX:
> ffff880407ba4cc0 RCX: 0000000000000001
> Aug 23 11:51:33 ex6 kernel: [55598.253837] RDX: 0000000000000015 RSI:
> 0000000000000000 RDI: ffff880194f4c090
> Aug 23 11:51:33 ex6 kernel: [55598.253839] RBP: 0000000000000002 R08:
> ffff8804089938f0 R09: 0000000000003ced
> Aug 23 11:51:33 ex6 kernel: [55598.253841] R10: ffff88041e836800 R11:
> 0000000000000202 R12: ffff880407ba4d08
> Aug 23 11:51:33 ex6 kernel: [55598.253842] R13: ffff880407ba4cc0 R14:
> 0000000000000292 R15: 0000293da5c4986a
> Aug 23 11:51:33 ex6 kernel: [55598.253845] FS:  00007fcd524e4700(0000=
)
> GS:ffff88041f380000(0000) knlGS:0000000000000000
> Aug 23 11:51:33 ex6 kernel: [55598.253847] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:33 ex6 kernel: [55598.253849] CR2: 00007fcd51b59000 CR3:
> 0000000208ab4000 CR4: 00000000000407e0
> Aug 23 11:51:33 ex6 kernel: [55598.253850] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:33 ex6 kernel: [55598.253852] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:33 ex6 kernel: [55598.253855] Process httpd2-event (pid:
> 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> Aug 23 11:51:33 ex6 kernel: [55598.253856] Stack:
> Aug 23 11:51:33 ex6 kernel: [55598.253857]  ffff880194f4c040
> ffffffff8145d45d ffff880194f4c040 ffffffff814d120e
> Aug 23 11:51:33 ex6 kernel: [55598.253861]  ffff880194f5a300
> ffff8804067d2580 0000000000000001 00007fcd60c8eaa0
> Aug 23 11:51:33 ex6 kernel: [55598.253865]  0004c7e9679f5fbf
> ffffffff8145ac14 00007fcd589c02e0 0000000100000000
> Aug 23 11:51:33 ex6 kernel: [55598.253868] Call Trace:
> Aug 23 11:51:33 ex6 kernel: [55598.253877]  [<ffffffff8145d45d>]
> lock_sock_nested+0xd/0x30
> Aug 23 11:51:33 ex6 kernel: [55598.253885]  [<ffffffff814d120e>]
> inet_shutdown+0x3e/0x130
> Aug 23 11:51:33 ex6 kernel: [55598.253892]  [<ffffffff8145ac14>]
> sys_shutdown+0x74/0x80
> Aug 23 11:51:33 ex6 kernel: [55598.253900]  [<ffffffff8156a47d>]
> system_call_fastpath+0x1a/0x1f
> Aug 23 11:51:33 ex6 kernel: [55598.253909]  [<00007fcd5fc42477>]
> 0x7fcd5fc42476
> Aug 23 11:51:33 ex6 kernel: [55598.253910] Code: c3 0f 1f 44 00 00 53=
 48
> 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89 c2 c1 ea 10 66 39 =
c2
> 74 0e 0f 1f 40 00 f3 90 0f b7 03 <66> 39 d0 75 f6 5b c3 90 90 90 90 4=
8
> c7 c7 60 74 a5 81 e9 34 d9
> Aug 23 11:51:46 ex6 kernel: [55610.629219] INFO: rcu_sched self-detec=
ted
> stall on CPU { 7}  (t=3D2580171 jiffies)
> Aug 23 11:51:46 ex6 kernel: [55610.629225] sending NMI to all CPUs:
> Aug 23 11:51:46 ex6 kernel: [55610.629231] NMI backtrace for cpu 6
> Aug 23 11:51:46 ex6 kernel: [55610.629234] CPU 6
> Aug 23 11:51:46 ex6 kernel: [55610.629239] Pid: 15597, comm:
> httpd2-event Not tainted 3.6.0-rc2-1-default #1 System manufacturer
> System Product Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.629242] RIP:
> 0010:[<ffffffff81562be0>]  [<ffffffff81562be0>] _raw_spin_lock_bh+0x2=
0/0x30
> Aug 23 11:51:46 ex6 kernel: [55610.629252] RSP: 0018:ffff88018fc79f08
> EFLAGS: 00000297
> Aug 23 11:51:46 ex6 kernel: [55610.629255] RAX: 0000000000000014 RBX:
> ffff880194f4c090 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.629257] RDX: 0000000000000015 RSI:
> 0000000000000000 RDI: ffff880194f4c090
> Aug 23 11:51:46 ex6 kernel: [55610.629260] RBP: 0000000000000002 R08:
> ffff8804089938f0 R09: 0000000000003ced
> Aug 23 11:51:46 ex6 kernel: [55610.629262] R10: ffff88041e836800 R11:
> 0000000000000202 R12: ffff8804067d2580
> Aug 23 11:51:46 ex6 kernel: [55610.629265] R13: 00000000ffffffea R14:
> 00007fcd60a664a0 R15: 00007fcd51db52b8
> Aug 23 11:51:46 ex6 kernel: [55610.629268] FS:  00007fcd524e4700(0000=
)
> GS:ffff88041f380000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629271] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.629274] CR2: 00007fcd51b59000 CR3:
> 0000000208ab4000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.629277] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629279] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.629282] Process httpd2-event (pid:
> 15597, threadinfo ffff88018fc78000, task ffff880194f5a300)
> Aug 23 11:51:46 ex6 kernel: [55610.629284] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.629286]  ffff880194f4c040
> ffffffff8145d45d ffff880194f4c040 ffffffff814d120e
> Aug 23 11:51:46 ex6 kernel: [55610.629292]  ffff880194f5a300
> ffff8804067d2580 0000000000000001 00007fcd60c8eaa0
> Aug 23 11:51:46 ex6 kernel: [55610.629297]  0004c7e9679f5fbf
> ffffffff8145ac14 00007fcd589c02e0 0000000100000000
> Aug 23 11:51:46 ex6 kernel: [55610.629303] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.629314]  [<ffffffff8145d45d>]
> lock_sock_nested+0xd/0x30
> Aug 23 11:51:46 ex6 kernel: [55610.629323]  [<ffffffff814d120e>]
> inet_shutdown+0x3e/0x130
> Aug 23 11:51:46 ex6 kernel: [55610.629330]  [<ffffffff8145ac14>]
> sys_shutdown+0x74/0x80
> Aug 23 11:51:46 ex6 kernel: [55610.629340]  [<ffffffff8156a47d>]
> system_call_fastpath+0x1a/0x1f
> Aug 23 11:51:46 ex6 kernel: [55610.629364]  [<00007fcd5fc42477>]
> 0x7fcd5fc42476
> Aug 23 11:51:46 ex6 kernel: [55610.629366] Code: 66 39 d0 75 f6 c3 0f=
 1f
> 44 00 00 53 48 89 fb e8 67 88 ae ff b8 00 00 01 00 f0 0f c1 03 89 c2 =
c1
> ea 10 66 39 c2 74 0e 0f 1f 40 00 <f3> 90 0f b7 03 66 39 d0 75 f6 5b c=
3
> 90 90 90 90 48 c7 c7 60 74
> Aug 23 11:51:46 ex6 kernel: [55610.629413] NMI backtrace for cpu 7
> Aug 23 11:51:46 ex6 kernel: [55610.629415] CPU 7
> Aug 23 11:51:46 ex6 kernel: [55610.629420] Pid: 0, comm: swapper/7 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.629422] RIP:
> 0010:[<ffffffff812df109>]  [<ffffffff812df109>] find_next_bit+0x39/0x=
b0
> Aug 23 11:51:46 ex6 kernel: [55610.629432] RSP: 0018:ffff88041f3c3938
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.629434] RAX: 0000000000000000 RBX:
> ffff88041f3ccfe0 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.629437] RDX: 0000000000000001 RSI:
> 0000000000000200 RDI: 0000000000000200
> Aug 23 11:51:46 ex6 kernel: [55610.629440] RBP: ffff88041f20d020 R08:
> ffff88041f3ccfe0 R09: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629442] R10: 0000000000000000 R11:
> 000000000000c2e2 R12: 000000000000d060
> Aug 23 11:51:46 ex6 kernel: [55610.629445] R13: 0000000000080000 R14:
> 00000000000000ff R15: 0000000000000007
> Aug 23 11:51:46 ex6 kernel: [55610.629448] FS:  0000000000000000(0000=
)
> GS:ffff88041f3c0000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629451] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.629454] CR2: 00007fcd2c062ac0 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.629456] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629459] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.629462] Process swapper/7 (pid: 0,
> threadinfo ffff88040abc4000, task ffff88040abc2400)
> Aug 23 11:51:46 ex6 kernel: [55610.629464] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.629465]  ffffffff8102a4e7
> 0000000081a2cec0 000000000000d020 0000000200000007
> Aug 23 11:51:46 ex6 kernel: [55610.629471]  0000000000000082
> ffff88041f3c39b0 0000000000002710 ffffffff81a2ce00
> Aug 23 11:51:46 ex6 kernel: [55610.629476]  ffff88040abc4000
> 0000000000000007 ffff88040abc4000 ffffffff81a2cec0
> Aug 23 11:51:46 ex6 kernel: [55610.629482] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.629494]  [<ffffffff8102a4e7>]
> __x2apic_send_IPI_mask+0xb7/0x1a0
> Aug 23 11:51:46 ex6 kernel: [55610.629503]  [<ffffffff810260ff>]
> arch_trigger_all_cpu_backtrace+0x4f/0x90
> Aug 23 11:51:46 ex6 kernel: [55610.629510]  [<ffffffff810d6d20>]
> rcu_pending+0x210/0x560
> Aug 23 11:51:46 ex6 kernel: [55610.629519]  [<ffffffff810d78c0>]
> rcu_check_callbacks+0x90/0x110
> Aug 23 11:51:46 ex6 kernel: [55610.629528]  [<ffffffff8105467f>]
> update_process_times+0x3f/0x80
> Aug 23 11:51:46 ex6 kernel: [55610.629536]  [<ffffffff810971fb>]
> tick_sched_timer+0x6b/0xe0
> Aug 23 11:51:46 ex6 kernel: [55610.629544]  [<ffffffff810699a6>]
> __run_hrtimer+0x66/0x1d0
> Aug 23 11:51:46 ex6 kernel: [55610.629552]  [<ffffffff8106a299>]
> hrtimer_interrupt+0xe9/0x210
> Aug 23 11:51:46 ex6 kernel: [55610.629559]  [<ffffffff81024e93>]
> smp_apic_timer_interrupt+0x63/0xa0
> Aug 23 11:51:46 ex6 kernel: [55610.629567]  [<ffffffff8156b0fa>]
> apic_timer_interrupt+0x6a/0x70
> Aug 23 11:51:46 ex6 kernel: [55610.629578]  [<ffffffff814c2c78>]
> tcp_slow_start+0x68/0xa0
> Aug 23 11:51:46 ex6 kernel: [55610.629585]  [<ffffffff814b6260>]
> tcp_ack+0x560/0x11e0
> Aug 23 11:51:46 ex6 kernel: [55610.629593]  [<ffffffff814b715d>]
> tcp_rcv_established+0x27d/0x8e0
> Aug 23 11:51:46 ex6 kernel: [55610.629601]  [<ffffffff814c045e>]
> tcp_v4_do_rcv+0xde/0x340
> Aug 23 11:51:46 ex6 kernel: [55610.629609]  [<ffffffff814c173b>]
> tcp_v4_rcv+0x59b/0x850
> Aug 23 11:51:46 ex6 kernel: [55610.629617]  [<ffffffff8149e156>]
> ip_local_deliver_finish+0xd6/0x250
> Aug 23 11:51:46 ex6 kernel: [55610.629625]  [<ffffffff8146eb5e>]
> __netif_receive_skb+0x67e/0x7e0
> Aug 23 11:51:46 ex6 kernel: [55610.629633]  [<ffffffff8146ed61>]
> process_backlog+0xa1/0x180
> Aug 23 11:51:46 ex6 kernel: [55610.629639]  [<ffffffff8146f830>]
> net_rx_action+0x140/0x230
> Aug 23 11:51:46 ex6 kernel: [55610.629647]  [<ffffffff8104be2e>]
> __do_softirq+0xbe/0x1f0
> Aug 23 11:51:46 ex6 kernel: [55610.629655]  [<ffffffff8156b7ec>]
> call_softirq+0x1c/0x30
> Aug 23 11:51:46 ex6 kernel: [55610.629662]  [<ffffffff810045a5>]
> do_softirq+0x75/0xb0
> Aug 23 11:51:46 ex6 kernel: [55610.629669]  [<ffffffff8104c1e5>]
> irq_exit+0xa5/0xb0
> Aug 23 11:51:46 ex6 kernel: [55610.629677]  [<ffffffff8156b2ba>]
> call_function_single_interrupt+0x6a/0x70
> Aug 23 11:51:46 ex6 kernel: [55610.629686]  [<ffffffff813303cc>]
> intel_idle+0xec/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.629695]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.629702]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.629710]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.629713] Code: d1 49 89 d1 48 c1 e9=
 06
> 49 83 e1 c0 4c 8d 04 cf 48 89 f7 48 89 d1 4c 29 cf 83 e1 3f 74 40 48 =
c7
> c0 ff ff ff ff 48 d3 e0 49 23 00 <48> 83 ff 3f 76 41 48 85 c0 75 52 4=
9
> 83 c0 08 48 83 ef 40 49 83
> Aug 23 11:51:46 ex6 kernel: [55610.629761] NMI backtrace for cpu 1
> Aug 23 11:51:46 ex6 kernel: [55610.629765] CPU 1
> Aug 23 11:51:46 ex6 kernel: [55610.629769] Pid: 0, comm: swapper/1 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.629772] RIP:
> 0010:[<ffffffff815628dd>]  [<ffffffff815628dd>] _raw_spin_lock+0x1d/0=
x30
> Aug 23 11:51:46 ex6 kernel: [55610.629781] RSP: 0018:ffff88041f243e48
> EFLAGS: 00000293
> Aug 23 11:51:46 ex6 kernel: [55610.629784] RAX: 0000000000000014 RBX:
> ffff880194f4c040 RCX: 0000000100c76001
> Aug 23 11:51:46 ex6 kernel: [55610.629787] RDX: 0000000000000016 RSI:
> 0000000000000286 RDI: ffff880194f4c090
> Aug 23 11:51:46 ex6 kernel: [55610.629789] RBP: ffff88040abd4000 R08:
> ffff88040701a29c R09: 0000000000000028
> Aug 23 11:51:46 ex6 kernel: [55610.629792] R10: dead000000200200 R11:
> 0000000000000000 R12: 0000000000000100
> Aug 23 11:51:46 ex6 kernel: [55610.629794] R13: ffffffff814bd160 R14:
> ffff880194f4c040 R15: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629798] FS:  0000000000000000(0000=
)
> GS:ffff88041f240000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629800] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.629803] CR2: 00007fa566135010 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.629806] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.629808] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.629811] Process swapper/1 (pid: 0,
> threadinfo ffff88040aba6000, task ffff88040aba4280)
> Aug 23 11:51:46 ex6 kernel: [55610.629813] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.629815]  ffffffff814bd171
> ffff88040abd4000 0000000000000100 ffff880194f4c200
> Aug 23 11:51:46 ex6 kernel: [55610.629820]  ffffffff81053ac1
> 0000000000000000 ffff88041f243ea0 ffff88040aba7fd8
> Aug 23 11:51:46 ex6 kernel: [55610.629825]  ffff88040aba7fd8
> ffff88040aba7fd8 ffff88040abd5028 ffff88041f243ea0
> Aug 23 11:51:46 ex6 kernel: [55610.629831] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.629841]  [<ffffffff814bd171>]
> tcp_keepalive_timer+0x11/0x250
> Aug 23 11:51:46 ex6 kernel: [55610.629850]  [<ffffffff81053ac1>]
> run_timer_softirq+0x151/0x350
> Aug 23 11:51:46 ex6 kernel: [55610.629857]  [<ffffffff8104be2e>]
> __do_softirq+0xbe/0x1f0
> Aug 23 11:51:46 ex6 kernel: [55610.629865]  [<ffffffff8156b7ec>]
> call_softirq+0x1c/0x30
> Aug 23 11:51:46 ex6 kernel: [55610.629871]  [<ffffffff810045a5>]
> do_softirq+0x75/0xb0
> Aug 23 11:51:46 ex6 kernel: [55610.629879]  [<ffffffff8104c1e5>]
> irq_exit+0xa5/0xb0
> Aug 23 11:51:46 ex6 kernel: [55610.629886]  [<ffffffff81024e98>]
> smp_apic_timer_interrupt+0x68/0xa0
> Aug 23 11:51:46 ex6 kernel: [55610.629893]  [<ffffffff8156b0fa>]
> apic_timer_interrupt+0x6a/0x70
> Aug 23 11:51:46 ex6 kernel: [55610.629902]  [<ffffffff813303cc>]
> intel_idle+0xec/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.629911]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.629918]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.629925]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.629929] Code: 90 90 90 90 90 90 90=
 90
> 90 90 90 90 90 90 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 c2 =
74
> 0f 0f 1f 44 00 00 f3 90 0f b7 07 <66> 39 d0 75 f6 c3 66 66 66 66 2e 0=
f
> 1f 84 00 00 00 00 00 66 83
> Aug 23 11:51:46 ex6 kernel: [55610.629976] NMI backtrace for cpu 2
> Aug 23 11:51:46 ex6 kernel: [55610.629979] CPU 2
> Aug 23 11:51:46 ex6 kernel: [55610.629983] Pid: 0, comm: swapper/2 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.629986] RIP:
> 0010:[<ffffffff8133039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.629992] RSP: 0018:ffff88040ababe78
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.629994] RAX: 0000000000000020 RBX:
> 0000000000000008 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.629997] RDX: 0000000000000000 RSI:
> ffff88040ababfd8 RDI: ffffffff81a17640
> Aug 23 11:51:46 ex6 kernel: [55610.629999] RBP: 0000000000000003 R08:
> 0000000000000003 R09: 0000000000003e3c
> Aug 23 11:51:46 ex6 kernel: [55610.630002] R10: 0000000000000001 R11:
> 0000000000000000 R12: ffff88041f298f70
> Aug 23 11:51:46 ex6 kernel: [55610.630004] R13: 0000000000000020 R14:
> 12acf11f7efbdbfc R15: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630007] FS:  0000000000000000(0000=
)
> GS:ffff88041f280000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630010] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.630012] CR2: 00007fa566135010 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.630015] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630017] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.630020] Process swapper/2 (pid: 0,
> threadinfo ffff88040abaa000, task ffff88040aba82c0)
> Aug 23 11:51:46 ex6 kernel: [55610.630022] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.630024]  0000000077359400
> ffffffff81436a70 0000000000000000 0000000200f31e03
> Aug 23 11:51:46 ex6 kernel: [55610.630029]  0000000000000000
> 0000000000f31e03 ffff88040ababfd8 ffff88041f298f70
> Aug 23 11:51:46 ex6 kernel: [55610.630034]  0000000000000003
> 0000000000000002 ffffffff81a52300 ffffffff8143566d
> Aug 23 11:51:46 ex6 kernel: [55610.630039] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.630048]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.630055]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.630062]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.630066] Code: 28 e0 ff ff 83 e2 08=
 75
> 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff =
a8
> 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29 f7 e=
8
> 76 a8 d1 ff 48 89 04 24 48
> Aug 23 11:51:46 ex6 kernel: [55610.630113] NMI backtrace for cpu 5
> Aug 23 11:51:46 ex6 kernel: [55610.630115] CPU 5
> Aug 23 11:51:46 ex6 kernel: [55610.630120] Pid: 0, comm: swapper/5 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.630122] RIP:
> 0010:[<ffffffff8133039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.630128] RSP: 0018:ffff88040abb9e78
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.630130] RAX: 0000000000000020 RBX:
> 0000000000000008 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.630133] RDX: 0000000000000000 RSI:
> ffff88040abb9fd8 RDI: ffffffff81a17640
> Aug 23 11:51:46 ex6 kernel: [55610.630135] RBP: 0000000000000003 R08:
> 0000000000000003 R09: 0000000000005634
> Aug 23 11:51:46 ex6 kernel: [55610.630138] R10: 0000000000000001 R11:
> 0000000000000000 R12: ffff88041f358f70
> Aug 23 11:51:46 ex6 kernel: [55610.630140] R13: 0000000000000020 R14:
> 12acf11f7e9e3c16 R15: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630143] FS:  0000000000000000(0000=
)
> GS:ffff88041f340000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630146] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.630149] CR2: 00007fd29bfff000 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.630151] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630154] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.630157] Process swapper/5 (pid: 0,
> threadinfo ffff88040abb8000, task ffff88040abb6380)
> Aug 23 11:51:46 ex6 kernel: [55610.630158] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.630160]  0000000077359400
> ffffffff81436a70 0000000000000000 000000050150be3d
> Aug 23 11:51:46 ex6 kernel: [55610.630165]  0000000000000000
> 000000000150be3d ffff88040abb9fd8 ffff88041f358f70
> Aug 23 11:51:46 ex6 kernel: [55610.630170]  0000000000000003
> 0000000000000005 ffffffff81a52300 ffffffff8143566d
> Aug 23 11:51:46 ex6 kernel: [55610.630176] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.630184]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.630191]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.630198]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.630201] Code: 28 e0 ff ff 83 e2 08=
 75
> 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff =
a8
> 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29 f7 e=
8
> 76 a8 d1 ff 48 89 04 24 48
> Aug 23 11:51:46 ex6 kernel: [55610.630248] NMI backtrace for cpu 3
> Aug 23 11:51:46 ex6 kernel: [55610.630251] CPU 3
> Aug 23 11:51:46 ex6 kernel: [55610.630255] Pid: 0, comm: swapper/3 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.630257] RIP:
> 0010:[<ffffffff8133039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.630263] RSP: 0018:ffff88040abb1e78
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.630266] RAX: 0000000000000020 RBX:
> 0000000000000008 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.630268] RDX: 0000000000000000 RSI:
> ffff88040abb1fd8 RDI: ffffffff81a17640
> Aug 23 11:51:46 ex6 kernel: [55610.630271] RBP: 0000000000000003 R08:
> 0000000000000003 R09: 0000000000003e43
> Aug 23 11:51:46 ex6 kernel: [55610.630273] R10: 0000000000000001 R11:
> 0000000000000000 R12: ffff88041f2d8f70
> Aug 23 11:51:46 ex6 kernel: [55610.630276] R13: 0000000000000020 R14:
> 12acf11f7efbc356 R15: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630279] FS:  0000000000000000(0000=
)
> GS:ffff88041f2c0000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630282] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.630284] CR2: 00007fe7d784ba68 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.630287] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630289] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.630292] Process swapper/3 (pid: 0,
> threadinfo ffff88040abb0000, task ffff88040abae300)
> Aug 23 11:51:46 ex6 kernel: [55610.630294] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.630296]  0000000077359400
> ffffffff81436a70 0000000000000000 0000000300f3366a
> Aug 23 11:51:46 ex6 kernel: [55610.630301]  0000000000000000
> 0000000000f3366a ffff88040abb1fd8 ffff88041f2d8f70
> Aug 23 11:51:46 ex6 kernel: [55610.630306]  0000000000000003
> 0000000000000003 ffffffff81a52300 ffffffff8143566d
> Aug 23 11:51:46 ex6 kernel: [55610.630311] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.630320]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.630327]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.630333]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.630337] Code: 28 e0 ff ff 83 e2 08=
 75
> 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff =
a8
> 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29 f7 e=
8
> 76 a8 d1 ff 48 89 04 24 48
> Aug 23 11:51:46 ex6 kernel: [55610.630385] NMI backtrace for cpu 0
> Aug 23 11:51:46 ex6 kernel: [55610.630388] CPU 0
> Aug 23 11:51:46 ex6 kernel: [55610.630393] Pid: 0, comm: swapper/0 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.630396] RIP:
> 0010:[<ffffffff8133039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.630403] RSP: 0018:ffffffff81a01e88
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.630406] RAX: 0000000000000020 RBX:
> 0000000000000008 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.630409] RDX: 0000000000000000 RSI:
> ffffffff81a01fd8 RDI: ffffffff81a17640
> Aug 23 11:51:46 ex6 kernel: [55610.630411] RBP: 0000000000000003 R08:
> 0000000000000003 R09: 0000000000005d52
> Aug 23 11:51:46 ex6 kernel: [55610.630413] R10: 0000000000000001 R11:
> 0000000000000000 R12: ffff88041f218f70
> Aug 23 11:51:46 ex6 kernel: [55610.630416] R13: 0000000000000020 R14:
> 12acf11f7f769680 R15: 0000000001fe8018
> Aug 23 11:51:46 ex6 kernel: [55610.630419] FS:  0000000000000000(0000=
)
> GS:ffff88041f200000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630422] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.630425] CR2: 00007f03abb83000 CR3:
> 0000000001a0c000 CR4: 00000000000407f0
> Aug 23 11:51:46 ex6 kernel: [55610.630427] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630430] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.630433] Process swapper/0 (pid: 0,
> threadinfo ffffffff81a00000, task ffffffff81a14420)
> Aug 23 11:51:46 ex6 kernel: [55610.630435] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.630436]  0000000077359400
> ffffffff81436a70 0000000000000000 00000000016c88d5
> Aug 23 11:51:46 ex6 kernel: [55610.630442]  0000000000000000
> 00000000016c88d5 ffffffff81a01fd8 ffff88041f218f70
> Aug 23 11:51:46 ex6 kernel: [55610.630447]  0000000000000003
> 0000000000000000 ffffffff81a52300 ffffffff8143566d
> Aug 23 11:51:46 ex6 kernel: [55610.630453] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.630464]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.630471]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.630480]  [<ffffffff81ac0ba2>]
> start_kernel+0x391/0x39c
> Aug 23 11:51:46 ex6 kernel: [55610.630488]  [<ffffffff81ac0436>]
> x86_64_start_kernel+0x105/0x114
> Aug 23 11:51:46 ex6 kernel: [55610.630492] Code: 28 e0 ff ff 83 e2 08=
 75
> 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff =
a8
> 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29 f7 e=
8
> 76 a8 d1 ff 48 89 04 24 48
> Aug 23 11:51:46 ex6 kernel: [55610.630539] NMI backtrace for cpu 4
> Aug 23 11:51:46 ex6 kernel: [55610.630542] CPU 4
> Aug 23 11:51:46 ex6 kernel: [55610.630546] Pid: 0, comm: swapper/4 No=
t
> tainted 3.6.0-rc2-1-default #1 System manufacturer System Product
> Name/P8B WS
> Aug 23 11:51:46 ex6 kernel: [55610.630549] RIP:
> 0010:[<ffffffff8133039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> Aug 23 11:51:46 ex6 kernel: [55610.630555] RSP: 0018:ffff88040abb5e78
> EFLAGS: 00000046
> Aug 23 11:51:46 ex6 kernel: [55610.630557] RAX: 0000000000000020 RBX:
> 0000000000000008 RCX: 0000000000000001
> Aug 23 11:51:46 ex6 kernel: [55610.630560] RDX: 0000000000000000 RSI:
> ffff88040abb5fd8 RDI: ffffffff81a17640
> Aug 23 11:51:46 ex6 kernel: [55610.630562] RBP: 0000000000000003 R08:
> 0000000000000003 R09: 0000000000003e1e
> Aug 23 11:51:46 ex6 kernel: [55610.630565] R10: 0000000000000001 R11:
> 0000000000000000 R12: ffff88041f318f70
> Aug 23 11:51:46 ex6 kernel: [55610.630568] R13: 0000000000000020 R14:
> 12acf11f7efc52d2 R15: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630571] FS:  0000000000000000(0000=
)
> GS:ffff88041f300000(0000) knlGS:0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630573] CS:  0010 DS: 0000 ES: 000=
0
> CR0: 000000008005003b
> Aug 23 11:51:46 ex6 kernel: [55610.630576] CR2: 00007fd29bfff000 CR3:
> 0000000001a0c000 CR4: 00000000000407e0
> Aug 23 11:51:46 ex6 kernel: [55610.630578] DR0: 0000000000000000 DR1:
> 0000000000000000 DR2: 0000000000000000
> Aug 23 11:51:46 ex6 kernel: [55610.630581] DR3: 0000000000000000 DR6:
> 00000000ffff0ff0 DR7: 0000000000000400
> Aug 23 11:51:46 ex6 kernel: [55610.630584] Process swapper/4 (pid: 0,
> threadinfo ffff88040abb4000, task ffff88040abb2340)
> Aug 23 11:51:46 ex6 kernel: [55610.630586] Stack:
> Aug 23 11:51:46 ex6 kernel: [55610.630588]  0000000077359400
> ffffffff81436a70 0000000000000000 0000000400f2a60d
> Aug 23 11:51:46 ex6 kernel: [55610.630593]  0000000000000000
> 0000000000f2a60d ffff88040abb5fd8 ffff88041f318f70
> Aug 23 11:51:46 ex6 kernel: [55610.630598]  0000000000000003
> 0000000000000004 ffffffff81a52300 ffffffff8143566d
> Aug 23 11:51:46 ex6 kernel: [55610.630604] Call Trace:
> Aug 23 11:51:46 ex6 kernel: [55610.630614]  [<ffffffff8143566d>]
> cpuidle_idle_call+0x9d/0x240
> Aug 23 11:51:46 ex6 kernel: [55610.630622]  [<ffffffff8100b715>]
> cpu_idle+0x65/0xd0
> Aug 23 11:51:46 ex6 kernel: [55610.630629]  [<ffffffff81550547>]
> start_secondary+0x1fe/0x203
> Aug 23 11:51:46 ex6 kernel: [55610.630633] Code: 28 e0 ff ff 83 e2 08=
 75
> 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff =
a8
> 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29 f7 e=
8
> 76 a8 d1 ff 48 89 04 24 48
>=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629820]  ffffffff81053ac1 000000=
0000000000 ffff88041f243ea0 ffff88040aba7fd8
> > Aug 23 11:51:46 ex6 kernel: [55610.629825]  ffff88040aba7fd8 ffff88=
040aba7fd8 ffff88040abd5028 ffff88041f243ea0
> > Aug 23 11:51:46 ex6 kernel: [55610.629831] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.629841]  [<ffffffff814bd171>] tc=
p_keepalive_timer+0x11/0x250
> > Aug 23 11:51:46 ex6 kernel: [55610.629850]  [<ffffffff81053ac1>] ru=
n_timer_softirq+0x151/0x350
> > Aug 23 11:51:46 ex6 kernel: [55610.629857]  [<ffffffff8104be2e>] __=
do_softirq+0xbe/0x1f0
> > Aug 23 11:51:46 ex6 kernel: [55610.629865]  [<ffffffff8156b7ec>] ca=
ll_softirq+0x1c/0x30
> > Aug 23 11:51:46 ex6 kernel: [55610.629871]  [<ffffffff810045a5>] do=
_softirq+0x75/0xb0
> > Aug 23 11:51:46 ex6 kernel: [55610.629879]  [<ffffffff8104c1e5>] ir=
q_exit+0xa5/0xb0
> > Aug 23 11:51:46 ex6 kernel: [55610.629886]  [<ffffffff81024e98>] sm=
p_apic_timer_interrupt+0x68/0xa0
> > Aug 23 11:51:46 ex6 kernel: [55610.629893]  [<ffffffff8156b0fa>] ap=
ic_timer_interrupt+0x6a/0x70
> > Aug 23 11:51:46 ex6 kernel: [55610.629902]  [<ffffffff813303cc>] in=
tel_idle+0xec/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.629911]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.629918]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.629925]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.629929] Code: 90 90 90 90 90 90 =
90 90 90 90 90 90 90 90 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39=
 c2 74 0f 0f 1f 44 00 00 f3 90 0f b7 07 <66> 39 d0 75 f6 c3 66 66 66 66=
 2e 0f 1f 84 00 00 00 00 00 66 83=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629976] NMI backtrace for cpu 2
> > Aug 23 11:51:46 ex6 kernel: [55610.629979] CPU 2=20
> > Aug 23 11:51:46 ex6 kernel: [55610.629983] Pid: 0, comm: swapper/2 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.629986] RIP: 0010:[<ffffffff8133=
039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.629992] RSP: 0018:ffff88040ababe=
78  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.629994] RAX: 0000000000000020 RB=
X: 0000000000000008 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.629997] RDX: 0000000000000000 RS=
I: ffff88040ababfd8 RDI: ffffffff81a17640
> > Aug 23 11:51:46 ex6 kernel: [55610.629999] RBP: 0000000000000003 R0=
8: 0000000000000003 R09: 0000000000003e3c
> > Aug 23 11:51:46 ex6 kernel: [55610.630002] R10: 0000000000000001 R1=
1: 0000000000000000 R12: ffff88041f298f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630004] R13: 0000000000000020 R1=
4: 12acf11f7efbdbfc R15: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630007] FS:  0000000000000000(00=
00) GS:ffff88041f280000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630010] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.630012] CR2: 00007fa566135010 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.630015] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630017] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.630020] Process swapper/2 (pid: =
0, threadinfo ffff88040abaa000, task ffff88040aba82c0)
> > Aug 23 11:51:46 ex6 kernel: [55610.630022] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.630024]  0000000077359400 ffffff=
ff81436a70 0000000000000000 0000000200f31e03
> > Aug 23 11:51:46 ex6 kernel: [55610.630029]  0000000000000000 000000=
0000f31e03 ffff88040ababfd8 ffff88041f298f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630034]  0000000000000003 000000=
0000000002 ffffffff81a52300 ffffffff8143566d
> > Aug 23 11:51:46 ex6 kernel: [55610.630039] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.630048]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.630055]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.630062]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.630066] Code: 28 e0 ff ff 83 e2 =
08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff=
 ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29=
 f7 e8 76 a8 d1 ff 48 89 04 24 48=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630113] NMI backtrace for cpu 5
> > Aug 23 11:51:46 ex6 kernel: [55610.630115] CPU 5=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630120] Pid: 0, comm: swapper/5 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.630122] RIP: 0010:[<ffffffff8133=
039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.630128] RSP: 0018:ffff88040abb9e=
78  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.630130] RAX: 0000000000000020 RB=
X: 0000000000000008 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.630133] RDX: 0000000000000000 RS=
I: ffff88040abb9fd8 RDI: ffffffff81a17640
> > Aug 23 11:51:46 ex6 kernel: [55610.630135] RBP: 0000000000000003 R0=
8: 0000000000000003 R09: 0000000000005634
> > Aug 23 11:51:46 ex6 kernel: [55610.630138] R10: 0000000000000001 R1=
1: 0000000000000000 R12: ffff88041f358f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630140] R13: 0000000000000020 R1=
4: 12acf11f7e9e3c16 R15: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630143] FS:  0000000000000000(00=
00) GS:ffff88041f340000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630146] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.630149] CR2: 00007fd29bfff000 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.630151] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630154] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.630157] Process swapper/5 (pid: =
0, threadinfo ffff88040abb8000, task ffff88040abb6380)
> > Aug 23 11:51:46 ex6 kernel: [55610.630158] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.630160]  0000000077359400 ffffff=
ff81436a70 0000000000000000 000000050150be3d
> > Aug 23 11:51:46 ex6 kernel: [55610.630165]  0000000000000000 000000=
000150be3d ffff88040abb9fd8 ffff88041f358f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630170]  0000000000000003 000000=
0000000005 ffffffff81a52300 ffffffff8143566d
> > Aug 23 11:51:46 ex6 kernel: [55610.630176] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.630184]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.630191]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.630198]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.630201] Code: 28 e0 ff ff 83 e2 =
08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff=
 ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29=
 f7 e8 76 a8 d1 ff 48 89 04 24 48=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630248] NMI backtrace for cpu 3
> > Aug 23 11:51:46 ex6 kernel: [55610.630251] CPU 3=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630255] Pid: 0, comm: swapper/3 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.630257] RIP: 0010:[<ffffffff8133=
039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.630263] RSP: 0018:ffff88040abb1e=
78  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.630266] RAX: 0000000000000020 RB=
X: 0000000000000008 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.630268] RDX: 0000000000000000 RS=
I: ffff88040abb1fd8 RDI: ffffffff81a17640
> > Aug 23 11:51:46 ex6 kernel: [55610.630271] RBP: 0000000000000003 R0=
8: 0000000000000003 R09: 0000000000003e43
> > Aug 23 11:51:46 ex6 kernel: [55610.630273] R10: 0000000000000001 R1=
1: 0000000000000000 R12: ffff88041f2d8f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630276] R13: 0000000000000020 R1=
4: 12acf11f7efbc356 R15: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630279] FS:  0000000000000000(00=
00) GS:ffff88041f2c0000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630282] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.630284] CR2: 00007fe7d784ba68 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.630287] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630289] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.630292] Process swapper/3 (pid: =
0, threadinfo ffff88040abb0000, task ffff88040abae300)
> > Aug 23 11:51:46 ex6 kernel: [55610.630294] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.630296]  0000000077359400 ffffff=
ff81436a70 0000000000000000 0000000300f3366a
> > Aug 23 11:51:46 ex6 kernel: [55610.630301]  0000000000000000 000000=
0000f3366a ffff88040abb1fd8 ffff88041f2d8f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630306]  0000000000000003 000000=
0000000003 ffffffff81a52300 ffffffff8143566d
> > Aug 23 11:51:46 ex6 kernel: [55610.630311] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.630320]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.630327]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.630333]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.630337] Code: 28 e0 ff ff 83 e2 =
08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff=
 ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29=
 f7 e8 76 a8 d1 ff 48 89 04 24 48=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630385] NMI backtrace for cpu 0
> > Aug 23 11:51:46 ex6 kernel: [55610.630388] CPU 0=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630393] Pid: 0, comm: swapper/0 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.630396] RIP: 0010:[<ffffffff8133=
039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.630403] RSP: 0018:ffffffff81a01e=
88  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.630406] RAX: 0000000000000020 RB=
X: 0000000000000008 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.630409] RDX: 0000000000000000 RS=
I: ffffffff81a01fd8 RDI: ffffffff81a17640
> > Aug 23 11:51:46 ex6 kernel: [55610.630411] RBP: 0000000000000003 R0=
8: 0000000000000003 R09: 0000000000005d52
> > Aug 23 11:51:46 ex6 kernel: [55610.630413] R10: 0000000000000001 R1=
1: 0000000000000000 R12: ffff88041f218f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630416] R13: 0000000000000020 R1=
4: 12acf11f7f769680 R15: 0000000001fe8018
> > Aug 23 11:51:46 ex6 kernel: [55610.630419] FS:  0000000000000000(00=
00) GS:ffff88041f200000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630422] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.630425] CR2: 00007f03abb83000 CR=
3: 0000000001a0c000 CR4: 00000000000407f0
> > Aug 23 11:51:46 ex6 kernel: [55610.630427] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630430] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.630433] Process swapper/0 (pid: =
0, threadinfo ffffffff81a00000, task ffffffff81a14420)
> > Aug 23 11:51:46 ex6 kernel: [55610.630435] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.630436]  0000000077359400 ffffff=
ff81436a70 0000000000000000 00000000016c88d5
> > Aug 23 11:51:46 ex6 kernel: [55610.630442]  0000000000000000 000000=
00016c88d5 ffffffff81a01fd8 ffff88041f218f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630447]  0000000000000003 000000=
0000000000 ffffffff81a52300 ffffffff8143566d
> > Aug 23 11:51:46 ex6 kernel: [55610.630453] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.630464]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.630471]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.630480]  [<ffffffff81ac0ba2>] st=
art_kernel+0x391/0x39c
> > Aug 23 11:51:46 ex6 kernel: [55610.630488]  [<ffffffff81ac0436>] x8=
6_64_start_kernel+0x105/0x114
> > Aug 23 11:51:46 ex6 kernel: [55610.630492] Code: 28 e0 ff ff 83 e2 =
08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff=
 ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29=
 f7 e8 76 a8 d1 ff 48 89 04 24 48=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630539] NMI backtrace for cpu 4
> > Aug 23 11:51:46 ex6 kernel: [55610.630542] CPU 4=20
> > Aug 23 11:51:46 ex6 kernel: [55610.630546] Pid: 0, comm: swapper/4 =
Not tainted 3.6.0-rc2-1-default #1 System manufacturer System Product N=
ame/P8B WS
> > Aug 23 11:51:46 ex6 kernel: [55610.630549] RIP: 0010:[<ffffffff8133=
039a>]  [<ffffffff8133039a>] intel_idle+0xba/0x160
> > Aug 23 11:51:46 ex6 kernel: [55610.630555] RSP: 0018:ffff88040abb5e=
78  EFLAGS: 00000046
> > Aug 23 11:51:46 ex6 kernel: [55610.630557] RAX: 0000000000000020 RB=
X: 0000000000000008 RCX: 0000000000000001
> > Aug 23 11:51:46 ex6 kernel: [55610.630560] RDX: 0000000000000000 RS=
I: ffff88040abb5fd8 RDI: ffffffff81a17640
> > Aug 23 11:51:46 ex6 kernel: [55610.630562] RBP: 0000000000000003 R0=
8: 0000000000000003 R09: 0000000000003e1e
> > Aug 23 11:51:46 ex6 kernel: [55610.630565] R10: 0000000000000001 R1=
1: 0000000000000000 R12: ffff88041f318f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630568] R13: 0000000000000020 R1=
4: 12acf11f7efc52d2 R15: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630571] FS:  0000000000000000(00=
00) GS:ffff88041f300000(0000) knlGS:0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630573] CS:  0010 DS: 0000 ES: 0=
000 CR0: 000000008005003b
> > Aug 23 11:51:46 ex6 kernel: [55610.630576] CR2: 00007fd29bfff000 CR=
3: 0000000001a0c000 CR4: 00000000000407e0
> > Aug 23 11:51:46 ex6 kernel: [55610.630578] DR0: 0000000000000000 DR=
1: 0000000000000000 DR2: 0000000000000000
> > Aug 23 11:51:46 ex6 kernel: [55610.630581] DR3: 0000000000000000 DR=
6: 00000000ffff0ff0 DR7: 0000000000000400
> > Aug 23 11:51:46 ex6 kernel: [55610.630584] Process swapper/4 (pid: =
0, threadinfo ffff88040abb4000, task ffff88040abb2340)
> > Aug 23 11:51:46 ex6 kernel: [55610.630586] Stack:
> > Aug 23 11:51:46 ex6 kernel: [55610.630588]  0000000077359400 ffffff=
ff81436a70 0000000000000000 0000000400f2a60d
> > Aug 23 11:51:46 ex6 kernel: [55610.630593]  0000000000000000 000000=
0000f2a60d ffff88040abb5fd8 ffff88041f318f70
> > Aug 23 11:51:46 ex6 kernel: [55610.630598]  0000000000000003 000000=
0000000004 ffffffff81a52300 ffffffff8143566d
> > Aug 23 11:51:46 ex6 kernel: [55610.630604] Call Trace:
> > Aug 23 11:51:46 ex6 kernel: [55610.630614]  [<ffffffff8143566d>] cp=
uidle_idle_call+0x9d/0x240
> > Aug 23 11:51:46 ex6 kernel: [55610.630622]  [<ffffffff8100b715>] cp=
u_idle+0x65/0xd0
> > Aug 23 11:51:46 ex6 kernel: [55610.630629]  [<ffffffff81550547>] st=
art_secondary+0x1fe/0x203
> > Aug 23 11:51:46 ex6 kernel: [55610.630633] Code: 28 e0 ff ff 83 e2 =
08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff=
 ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <e8> e1 f9 d5 ff 48 89 c7 4c 29=
 f7 e8 76 a8 d1 ff 48 89 04 24 48=20
>=20
>=20
> Tested kernels with the problem 3.6.RC2 from SUSE, and today's linus
> vanilla tree.
>=20
> Server needs reboot. (or let's say two completely different boxes hav=
e
> the same problem)

This looks like an infinite loop in tcp_slow_start()

This could happen if tp->snd_cwnd is zero

Bug probably introduced with commit commit
9dc274151a548ffd215caecec5a8872db8799447
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Jul 20 05:02:33 2012 +0000

    tcp: fix ABC in tcp_slow_start()
   =20
    When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
    received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start(=
)
   =20
    Problem is this RFC 3465 statement is not correctly coded, as
    the while () loop increases snd_cwnd one by one.
   =20
    Add a new variable to avoid this off-by one error.
   =20
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Tom Herbert <therbert@google.com>
    Cc: Yuchung Cheng <ycheng@google.com>
    Cc: Neal Cardwell <ncardwell@google.com>
    Cc: Nandita Dukkipati <nanditad@google.com>
    Cc: John Heffner <johnwheffner@gmail.com>
    Cc: Stephen Hemminger <shemminger@vyatta.com>
    Acked-by: Yuchung Cheng <ycheng@google.com>
    Acked-by: Neal Cardwell <ncardwell@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 04dbd7a..4d4db16 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -307,6 +307,7 @@ EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
 void tcp_slow_start(struct tcp_sock *tp)
 {
        int cnt; /* increase in packets */
+       unsigned int delta =3D 0;
=20
        /* RFC3465: ABC Slow start
         * Increase only after a full MSS of bytes is acked
@@ -333,9 +334,9 @@ void tcp_slow_start(struct tcp_sock *tp)
        tp->snd_cwnd_cnt +=3D cnt;
        while (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
                tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
-               if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-                       tp->snd_cwnd++;
+               delta++;
        }
+       tp->snd_cwnd =3D min(tp->snd_cwnd + delta, tp->snd_cwnd_clamp);
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
=20



Oh, I now see the bug, I'll send a patch asap
