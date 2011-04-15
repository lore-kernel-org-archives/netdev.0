From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000002c0  / IP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c
Date: Fri, 15 Apr 2011 15:09:43 +0200
Message-ID: <1302872983.3613.10.camel@edumazet-laptop>
References: <4DA77AE5.9060501@simon.arlott.org.uk>
	 <0b5f315dd0f6e8eefabbd8b38b1d43e181fdd728@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <0b5f315dd0f6e8eefabbd8b38b1d43e181fdd728@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 15 avril 2011 =C3=A0 12:30 +0100, Simon Arlott a =C3=A9crit=
 :
> On Thu, April 14, 2011 23:53, Simon Arlott wrote:
> > [19258502.086131] BUG: unable to handle kernel paging request at 67=
6e7543
> > [19258502.087007] IP: [<c04d89a7>] icmpv6_send+0x5c3/0x6e2
>=20

CC netfilter-devel

> This happened again in a different part of icmpv6_send:
>=20
> [31890.810491] BUG: unable to handle kernel NULL pointer dereference =
at 000002c0
> [31890.814522] IP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c
> [31890.814522] *pdpt =3D 00000000160fb001 *pde =3D 0000000000000000
> [31890.814522] Oops: 0002 [#1] PREEMPT SMP
> [31890.814522] last sysfs file: /sys/devices/platform/it87.552/cpu0_v=
id
> [31890.814522] Modules linked in: xt_tcpmss xt_length xt_TCPMSS ppp_s=
ynctty sch_sfq xt_u32 xt_CLASSIFY
> sch_htb ppp_async bnep nfsd lockd sunrpc rfcomm l2cap crc16 exportfs =
nf_conntrack_ipv6 xt_state ip6t_LOG ipm
> [31890.889345]
> [31890.889345] Pid: 3, comm: ksoftirqd/0 Tainted: G        W   2.6.35=
=2E4-git+ #git+ GA-MA69VM-S2/GA-MA69VM-S2
> [31890.889345] EIP: 0060:[<c04c70f2>] EFLAGS: 00010246 CPU: 0
> [31890.917900] EIP is at in6_dev_finish_destroy+0x35/0x8c
> [31890.917900] EAX: 00000009 EBX: d6997fa3 ECX: c0513fcd EDX: 0000000=
0
> [31890.917900] ESI: 00000000 EDI: f7483bd4 EBP: f7483b40 ESP: f7483b3=
8
> [31890.917900]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [31890.917900] Process ksoftirqd/0 (pid: 3, ti=3Df7482000 task=3Df748=
00a0 task.ti=3Df7482000)
> [31890.917900] Stack:
> [31890.917900]  d6997fa3 00000159 f7483c4c c04d8a8b efb86cc0 c067f614=
 f7483b58 c067f614
> [31890.917900] <0> f7483b68 c0513fe0 0021c090 0021c086 f7483b88 c022e=
74d 00000046 0101ff2f
> [31890.917900] <0> ef87e04c 00000151 f6e1fac0 f6e1fdb4 ef87e05c 00000=
000 00000040 f6e1faf0
> [31890.917900] Call Trace:
> [31890.917900]  [<c04d8a8b>] ? icmpv6_send+0x6a7/0x6e2
> [31890.917900]  [<c0513fe0>] ? _raw_spin_unlock_irqrestore+0x42/0x58
> [31890.917900]  [<c022e74d>] ? release_console_sem+0x197/0x1c4
> [31890.917900]  [<fa7ab0b5>] ? reject_tg6+0x70/0x43f [ip6t_REJECT]
> [31890.917900]  [<fa7d09b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
> [31890.917900]  [<c024e201>] ? trace_hardirqs_on+0xb/0xd
> [31890.917900]  [<c0232a72>] ? local_bh_enable_ip+0x97/0xad
> [31890.917900]  [<c0513f59>] ? _raw_spin_unlock_bh+0x2f/0x32
> [31890.917900]  [<fa7d09b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
> [31890.917900]  [<fa6981a0>] ? ipv6_find_hdr+0xf8/0x164 [ip6_tables]
> [31890.917900]  [<fa6987c1>] ? ip6t_do_table+0x4c8/0x53e [ip6_tables]
> [31890.917900]  [<fa73e0f0>] ? ip6table_mangle_hook+0xf0/0x100 [ip6ta=
ble_mangle]
> [31890.917900]  [<fa6a3018>] ? ip6table_filter_hook+0x18/0x20 [ip6tab=
le_filter]
> [31890.917900]  [<c046ee87>] ? nf_iterate+0x2f/0x62
> [31890.917900]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31890.917900]  [<c046f088>] ? nf_hook_slow+0x63/0xeb
> [31890.917900]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31890.917900]  [<c04c44d6>] ? ip6_input+0x33/0x47
> [31890.917900]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31890.917900]  [<c04c4775>] ? ip6_rcv_finish+0x8b/0x8e
> [31890.917900]  [<fc22aa3a>] ? nf_ct_frag6_output+0x7c/0x95 [nf_connt=
rack_ipv6]
> [31890.917900]  [<fc22a45c>] ? ipv6_defrag+0x87/0x9f [nf_conntrack_ip=
v6]
> [31890.917900]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31890.917900]  [<c046ee87>] ? nf_iterate+0x2f/0x62
> [31890.917900]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31890.917900]  [<c046f088>] ? nf_hook_slow+0x63/0xeb
> [31890.917900]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31890.917900]  [<c04c4aff>] ? ipv6_rcv+0x387/0x47c
> [31890.917900]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31890.917900]  [<c0455065>] ? __netif_receive_skb+0x367/0x3b6
> [31890.917900]  [<c0455142>] ? process_backlog+0x8e/0x146
> [31890.917900]  [<c0455c3b>] ? net_rx_action+0x62/0x119
> [31890.917900]  [<c0232750>] ? __do_softirq+0x8b/0x10a
> [31890.917900]  [<c02327fa>] ? do_softirq+0x2b/0x43
> [31890.917900]  [<c0232885>] ? run_ksoftirqd+0x73/0x155
> [31890.917900]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
> [31890.917900]  [<c023fdbd>] ? kthread+0x61/0x66
> [31890.917900]  [<c023fd5c>] ? kthread+0x0/0x66
> [31890.917900]  [<c0202c7a>] ? kernel_thread_helper+0x6/0x1a
> [31890.917900] Code: 40 04 39 43 04 74 0f ba 45 01 00 00 b8 7a a1 63 =
c0 e8 32 70 d6 ff 83 7b 0c 00 74 0f ba
> 46 01 00 00 b8 7a a1 63 c0 e8 1d 70 d6 ff <f0> ff 8e c0 02 00 00 83 b=
b e4 00 00 00 00 75 0f 53 68 b5 a
> [31890.917900] EIP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c SS:=
ESP 0068:f7483b38
> [31890.917900] CR2: 00000000000002c0
> [31891.236446] ---[ end trace 830bf5b3286acea0 ]---
> [31891.241375] Kernel panic - not syncing: Fatal exception in interru=
pt
> [31891.248085] Pid: 3, comm: ksoftirqd/0 Tainted: G      D W   2.6.35=
=2E4-git+ #git+
> [31891.255918] Call Trace:
> [31891.258474]  [<c0511194>] ? printk+0xf/0x13
> [31891.262911]  [<c0511116>] panic+0x55/0xc4
> [31891.267130]  [<c02050ed>] oops_end+0x6e/0x7c
> [31891.271619]  [<c021a514>] no_context+0x13f/0x149
> [31891.276496]  [<c021a657>] __bad_area_nosemaphore+0x139/0x141
> [31891.282461]  [<c0207360>] ? native_sched_clock+0x42/0x8d
> [31891.288090]  [<c024468d>] ? sched_clock_local+0x17/0x104
> [31891.293699]  [<c021a66c>] bad_area_nosemaphore+0xd/0x10
> [31891.299206]  [<c021a910>] do_page_fault+0x14e/0x302
> [31891.304356]  [<c0205311>] ? show_trace+0x10/0x14
> [31891.309219]  [<c05110b7>] ? dump_stack+0x57/0x61
> [31891.314102]  [<c021a7c2>] ? do_page_fault+0x0/0x302
> [31891.319236]  [<c051499b>] error_code+0x6b/0x70
> [31891.323934]  [<c0513fcd>] ? _raw_spin_unlock_irqrestore+0x2f/0x58
> [31891.330370]  [<c021a7c2>] ? do_page_fault+0x0/0x302
> [31891.335536]  [<c04c70f2>] ? in6_dev_finish_destroy+0x35/0x8c
> [31891.341512]  [<c04d8a8b>] icmpv6_send+0x6a7/0x6e2
> [31891.346471]  [<c0513fe0>] ? _raw_spin_unlock_irqrestore+0x42/0x58
> [31891.352853]  [<c022e74d>] ? release_console_sem+0x197/0x1c4
> [31891.358740]  [<fa7ab0b5>] reject_tg6+0x70/0x43f [ip6t_REJECT]
> [31891.364821]  [<fa7d09b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
> [31891.371340]  [<c024e201>] ? trace_hardirqs_on+0xb/0xd
> [31891.376604]  [<c0232a72>] ? local_bh_enable_ip+0x97/0xad
> [31891.382205]  [<c0513f59>] ? _raw_spin_unlock_bh+0x2f/0x32
> [31891.387945]  [<fa7d09b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
> [31891.394444]  [<fa6981a0>] ? ipv6_find_hdr+0xf8/0x164 [ip6_tables]
> [31891.400896]  [<fa6987c1>] ip6t_do_table+0x4c8/0x53e [ip6_tables]
> [31891.407260]  [<fa73e0f0>] ? ip6table_mangle_hook+0xf0/0x100 [ip6ta=
ble_mangle]
> [31891.414819]  [<fa6a3018>] ip6table_filter_hook+0x18/0x20 [ip6table=
_filter]
> [31891.422118]  [<c046ee87>] nf_iterate+0x2f/0x62
> [31891.426800]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31891.432267]  [<c046f088>] nf_hook_slow+0x63/0xeb
> [31891.437147]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31891.442583]  [<c04c44d6>] ip6_input+0x33/0x47
> [31891.447195]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
> [31891.452608]  [<c04c4775>] ip6_rcv_finish+0x8b/0x8e
> [31891.457655]  [<fc22aa3a>] nf_ct_frag6_output+0x7c/0x95 [nf_conntra=
ck_ipv6]
> [31891.464929]  [<fc22a45c>] ipv6_defrag+0x87/0x9f [nf_conntrack_ipv6=
]
> [31891.471561]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31891.476693]  [<c046ee87>] nf_iterate+0x2f/0x62
> [31891.481377]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31891.486501]  [<c046f088>] nf_hook_slow+0x63/0xeb
> [31891.491383]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31891.496501]  [<c04c4aff>] ipv6_rcv+0x387/0x47c
> [31891.501227]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
> [31891.506394]  [<c0455065>] __netif_receive_skb+0x367/0x3b6
> [31891.512081]  [<c0455142>] process_backlog+0x8e/0x146
> [31891.517328]  [<c0455c3b>] net_rx_action+0x62/0x119
> [31891.522402]  [<c0232750>] __do_softirq+0x8b/0x10a
> [31891.527386]  [<c02327fa>] do_softirq+0x2b/0x43
> [31891.532078]  [<c0232885>] run_ksoftirqd+0x73/0x155
> [31891.537136]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
> [31891.542294]  [<c023fdbd>] kthread+0x61/0x66
> [31891.546708]  [<c023fd5c>] ? kthread+0x0/0x66
> [31891.551211]  [<c0202c7a>] kernel_thread_helper+0x6/0x1a
> [31891.556747] Rebooting in 10 seconds..
>=20


Hmm... net/ipv6/netfilter/nf_conntrack_reasm.c happily keep references
to devices, on queued skb (so can escape RCU read side section)

Maybe try following patch ?


diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index 0857272..57f158e 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -582,6 +582,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 	spin_unlock_bh(&fq->q.lock);
=20
 	fq_put(fq);
+	ret_skb->dev =3D dev;
 	return ret_skb;
=20
 ret_orig:





--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
