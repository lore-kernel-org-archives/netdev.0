From: Fan Du <fan.du@windriver.com>
Subject: Re: PANIC at net/xfrm/xfrm_output.c:125 (3.9.4)
Date: Thu, 6 Jun 2013 09:24:18 +0800
Message-ID: <51AFE4C2.1000604@windriver.com>
References: <51AFB204.8070009@bootc.net> <20130606010416.GF26681@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean Sacren <sakiwit@gmail.com>, <steffen.klassert@secunet.com>,
	<herbert@gondor.hengli.com.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606010416.GF26681@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Chris/Jean

This issue might have already been fixed by this:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/=
net/xfrm/xfrm_output.c?id=3D497574c72c9922cf20c12aed15313c389f722fa0

Hope it helps.

On 2013=E5=B9=B406=E6=9C=8806=E6=97=A5 09:04, Jean Sacren wrote:
> From: Chris Boot<bootc@bootc.net>
> Date: Wed, 05 Jun 2013 22:47:48 +0100
>>
>> Hi folks,
>>
>> I have a re-purposed Watchguard Firebox running Debian GNU/Linux wit=
h a
>> self-built vanilla 3.9.4 kernel. I have an IPsec tunnel up to a remo=
te
>> router through which I was passing a fair bit of traffic when I hit =
the
>> following panic:
>>
>> [486832.949560] BUG: unable to handle kernel NULL pointer dereferenc=
e at
>> 00000010
>> [486832.953431] IP: [<c12a4dd0>] xfrm_output_resume+0x61/0x29f
>> [486832.953431] *pde =3D 00000000
>> [486832.953431] Oops: 0000 [#1]
>> [486832.953431] Modules linked in: xt_realm xt_nat authenc esp4
>> xfrm4_mode_tunnel tun ip6table_nat nf_nat_ipv6 sch_fq_codel xt_stati=
stic
>> xt_CT xt_LOG xt_connlimit xt_recent xt_time xt_TCPMSS xt_sctp
>> ip6t_REJECT pppoe deflate zlib_deflate pppox ctr twofish_generic
>> twofish_i586 twofish_common camellia_generic serpent_sse2_i586 xts
>> serpent_generic lrw gf128mul glue_helper ablk_helper cryptd
>> blowfish_generic blowfish_common cast5_generic cast_common des_gener=
ic
>> cbc xcbc rmd160 sha512_generic sha256_generic sha1_generic hmac
>> crypto_null af_key xfrm_algo xt_comment xt_addrtype xt_policy
>> ip_set_hash_ip ipt_ULOG ipt_REJECT ipt_MASQUERADE ipt_ECN ipt_CLUSTE=
RIP
>> ipt_ah act_police cls_basic cls_flow cls_fw cls_u32 sch_tbf sch_prio
>> sch_htb sch_hfsc sch_ingress sch_sfq xt_set ip_set nf_nat_tftp
>> nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp
>> nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_=
kmp
>> nf_conntrack_amanda nf_conntrack_sane nf_conntrack_tftp nf_conntrack=
_sip
>> nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp
>> nf_conntrack_proto_gre nf_conntrack_netlink nf_conntrack_netbios_ns
>> nf_conntrack_broadcast nf_conntrack_irc nf_conntrack_h323
>> nf_conntrack_ftp xt_TPROXY nf_tproxy_core xt_tcpmss xt_pkttype
>> xt_physdev xt_owner xt_NFQUEUE xt_NFLOG nfnetlink_log xt_multiport
>> xt_mark xt_mac xt_limit xt_length xt_iprange xt_helper xt_hashlimit
>> xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASSIFY xt_AUDIT xt_state
>> nfnetlink bridge 8021q garp stp mrp llc ppp_generic slhc
>> nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_mangle ip6table_raw
>> ip6table_filter ip6_tables xt_tcpudp xt_conntrack iptable_mangle
>> iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
>> nf_conntrack iptable_raw iptable_filter ip_tables x_tables w83627hf
>> hwmon_vid loop iTCO_wdt iTCO_vendor_support evdev snd_pcm snd_page_a=
lloc
>> snd_timer snd soundcore acpi_cpufreq mperf processor pcspkr serio_ra=
w
>> drm_kms_helper lpc_ich i2c_i801 of_i2c drm rng_core thermal_sys
>> i2c_algo_bit ehci_pci i2c_core ext4 crc16 jbd2 mbcache dm_mod sg sd_=
mod
>> crc_t10dif ata_generic ata_piix uhci_hcd ehci_hcd libata microcode
>> scsi_mod skge sky2 usbcore usb_common
>> [486832.953431] Pid: 0, comm: swapper Not tainted 3.9.4-1-bootc #1
>> [486832.953431] EIP: 0060:[<c12a4dd0>] EFLAGS: 00210246 CPU: 0
>> [486832.953431] EIP is at xfrm_output_resume+0x61/0x29f
>> [486832.953431] EAX: 00000000 EBX: f3fbc100 ECX: f77f1288 EDX: f6130=
200
>> [486832.953431] ESI: 00000016 EDI: 00000000 EBP: f70b3c00 ESP: c1407=
c44
>> [486832.953431]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
>> [486832.953431] CR0: 8005003b CR2: 00000010 CR3: 37247000 CR4: 00000=
7d0
>> [486832.953431] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000=
000
>> [486832.953431] DR6: ffff0ff0 DR7: 00000400
>> [486832.953431] Process swapper (pid: 0, ti=3Dc1406000 task=3Dc14134=
90
>> task.ti=3Dc1406000)
>> [486832.953431] Stack:
>> [486832.953431]  c129d44f 80000000 00000002 c1457254 f3fbc100 c129d4=
4f
>> 00000000 00000008
>> [486832.953431]  c129d49e 00000000 f4524000 c129d44f 80000000 000000=
00
>> f3fbc100 c1268b49
>> [486832.953431]  f3fbc100 f127604e c12678c3 00000000 f7123000 c12676=
85
>> c1457f8c c1456b80
>> [486832.953431] Call Trace:
>> [486832.953431]  [<c129d44f>] ? xfrm4_extract_output+0x94/0x94
>> [486832.953431]  [<c129d44f>] ? xfrm4_extract_output+0x94/0x94
>> [486832.953431]  [<c129d49e>] ? xfrm4_output+0x2c/0x6a
>> [486832.953431]  [<c129d44f>] ? xfrm4_extract_output+0x94/0x94
>> [486832.953431]  [<c1268b49>] ? ip_forward_finish+0x59/0x5c
>> [486832.953431]  [<c12678c3>] ? ip_rcv_finish+0x23e/0x274
>> [486832.953431]  [<c1267685>] ? pskb_may_pull+0x2d/0x2d
>> [486832.953431]  [<c1246890>] ? __netif_receive_skb_core+0x39d/0x406
>> [486832.953431]  [<f849557f>] ? br_handle_frame_finish+0x22c/0x264 [=
bridge]
>> [486832.953431]  [<c1246a16>] ? process_backlog+0xd0/0xd0
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<f8499310>] ? NF_HOOK_THRESH+0x1d/0x4c [bridge]
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<f849983e>] ? br_nf_pre_routing_finish+0x1c8/0x1d2
>> [bridge]
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<c12635d1>] ? nf_hook_slow+0x52/0xed
>> [486832.953431]  [<f8499676>] ? nf_bridge_alloc.isra.18+0x32/0x32 [b=
ridge]
>> [486832.953431]  [<f8499676>] ? nf_bridge_alloc.isra.18+0x32/0x32 [b=
ridge]
>> [486832.953431]  [<f8499310>] ? NF_HOOK_THRESH+0x1d/0x4c [bridge]
>> [486832.953431]  [<f8499676>] ? nf_bridge_alloc.isra.18+0x32/0x32 [b=
ridge]
>> [486832.953431]  [<f849a1c0>] ? br_nf_pre_routing+0x32c/0x33f [bridg=
e]
>> [486832.953431]  [<f8499676>] ? nf_bridge_alloc.isra.18+0x32/0x32 [b=
ridge]
>> [486832.953431]  [<c1263552>] ? nf_iterate+0x3c/0x69
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<c12635d1>] ? nf_hook_slow+0x52/0xed
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<f84952fa>] ? nf_hook_thresh.constprop.10+0x36/0x4=
2
>> [bridge]
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<f8495746>] ? br_handle_frame+0x18f/0x1b5 [bridge]
>> [486832.953431]  [<f8495353>] ? br_handle_local_finish+0x4d/0x4d [br=
idge]
>> [486832.953431]  [<f84955b7>] ? br_handle_frame_finish+0x264/0x264 [=
bridge]
>> [486832.953431]  [<c12467a8>] ? __netif_receive_skb_core+0x2b5/0x406
>> [486832.953431]  [<c1051a58>] ? __getnstimeofday+0x17/0x52
>> [486832.953431]  [<c1051a00>] ? get_monotonic_boottime+0x73/0x92
>> [486832.953431]  [<c124704f>] ? napi_gro_receive+0x2e/0x69
>> [486832.953431]  [<c10053d8>] ? __stop_machine.isra.0.constprop.1+0x=
27/0x27
>> [486832.953431]  [<f80792d7>] ? sky2_poll+0x6d8/0x8f3 [sky2]
>> [486832.953431]  [<c1006058>] ? native_sched_clock+0x40/0x98
>> [486832.953431]  [<c1006058>] ? native_sched_clock+0x40/0x98
>> [486832.953431]  [<c1005962>] ? paravirt_sched_clock+0x8/0xb
>> [486832.953431]  [<c1006058>] ? native_sched_clock+0x40/0x98
>> [486832.953431]  [<c1246bbf>] ? net_rx_action+0x6e/0x180
>> [486832.953431]  [<c1005962>] ? paravirt_sched_clock+0x8/0xb
>> [486832.953431]  [<c102ca5a>] ? __do_softirq+0xa5/0x19e
>> [486832.953431]  [<c102cbfa>] ? irq_exit+0x36/0x69
>> [486832.953431]  [<c100326b>] ? do_IRQ+0x6e/0x81
>> [486832.953431]  [<c12e4cf3>] ? common_interrupt+0x33/0x38
>> [486832.953431]  [<c101df1b>] ? native_safe_halt+0x2/0x3
>> [486832.953431]  [<c1006b2f>] ? default_idle+0x23/0x3e
>> [486832.953431]  [<c10070cd>] ? cpu_idle+0x75/0x8f
>> [486832.953431]  [<c145996b>] ? start_kernel+0x34e/0x353
>> [486832.953431]  [<c1459465>] ? repair_env_string+0x4d/0x4d
>> [486832.953431] Code: f9 ff 8b 43 74 c7 43 70 00 00 00 00 85 c0 74 0=
e ff
>> 08 0f 94 c2 84 d2 74 05 e8 c7 6b e1 ff 8b 43 48 c7 43 74 00 00 00 00=
 83
>> e0 fe<8b>  50 10 89 d8 ff 52 34 83 f8 01 89 c7 0f 85 21 02 00 00 8b =
53
>> [486832.953431] EIP: [<c12a4dd0>] xfrm_output_resume+0x61/0x29f SS:E=
SP
>> 0068:c1407c44
>> [486832.953431] CR2: 0000000000000010
>> [486833.573872] ---[ end trace ed321ebdc197b3d7 ]---
>> [486833.578576] Kernel panic - not syncing: Fatal exception in inter=
rupt
>> [486833.582572] Rebooting in 60 seconds..
>>
>> (gdb) list *xfrm_output_resume+0x61
>> 0xc12a4dd0 is in xfrm_output_resume (net/xfrm/xfrm_output.c:125).
>> 120     int xfrm_output_resume(struct sk_buff *skb, int err)
>> 121     {
>> 122             while (likely((err =3D xfrm_output_one(skb, err)) =3D=
=3D 0)) {
>> 123                     nf_reset(skb);
>> 124
>> 125                     err =3D skb_dst(skb)->ops->local_out(skb);
>> 126                     if (unlikely(err !=3D 1))
>> 127                             goto out;
>> 128
>> 129                     if (!skb_dst(skb)->xfrm)
>
> Try this:
>
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index bcfda89..0cf003d 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -64,6 +64,7 @@ static int xfrm_output_one(struct sk_buff *skb, int=
 err)
>
>   		if (unlikely(x->km.state !=3D XFRM_STATE_VALID)) {
>   			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
> +			err =3D -EINVAL;
>   			goto error;
>   		}
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
