From: Urban Loesch <bind@enas.net>
Subject: Re: Kernel 3.7.2 strange warning and short system hang
Date: Fri, 22 Feb 2013 10:49:36 +0100
Message-ID: <51273F30.5020207@enas.net>
References: <5124F57A.6080908@enas.net> <1361379176.19353.187.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361379176.19353.187.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

thanks for your help. I patched my kernel yesterday. Now I have to wait some days.
The error occurs not periodically. If it occurs again I let you now.

many thanks
Urban

On 20.02.2013 17:52, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 17:10 +0100, Urban Loesch wrote:
>> Hi,
>>
>> today I had a strange system hang on one of our new Dell PER620 machines.
>> I'm running a self compiled kernel, version 3.7.2 with linux vserver patch included.
>>
>> uname -a
>> Linux dbhost04 3.7.2-vs2.3.5.5-rol-em64t #4 SMP Sun Feb 3 14:08:37 CET 2013 x86_64 GNU/Linux
>>
>> 15min. systemload between 1-3.
>>
>>
>> Today the system hangs for some seconds and I got the folling errors in syslog multiple times within one second:
>>
>> ...
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196338] WARNING: at net/core/skbuff.c:573 skb_release_head_state+0xed/0x100()
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196338] Hardware name: PowerEdge R620
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196352] Modules linked in: lru_cache netconsole configfs act_police cls_basic cls_flow cls_fw cls_u32
>> sch_tbf sch_prio sch_hfsc sch_htb sch_ingress sch_sfq xt_statistic xt_CT xt_realm xt_LOG xt_c
>> onnlimit iptable_raw xt_comment xt_nat xt_recent ipt_ULOG ipt_REJECT ipt_MASQUERADE ipt_ECN ipt_CLUSTERIP ipt_ah nf_nat_tftp nf_nat_sip nf_nat_pptp
>> nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda nf_conntrack_tftp nf_con
>> ntrack_sane nf_conntrack_sip nf_conntrack_proto_udplite nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netlink
>> nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_irc ts_kmp nf_conntrack_h323 nf_con
>> ntrack_amanda nf_conntrack_ftp xt_TPROXY xt_time nf_tproxy_core xt_TCPMSS xt_tcpmss xt_sctp xt_policy xt_pkttype xt_NFLOG nfnetlink_log xt_physdev
>> xt_owner xt_NFQUEUE xt_multiport xt_mark xt_mac xt_limit xt_length xt_iprange xt_helper xt
>> _hashlimit xt_DSCP xt_dscp xt_dccp xt_connmark xt_CLASSIFY iptable_nat nf_nat_ipv
>> Feb 20 15:58:04 dbhost04 kernel: 4 nf_nat ip6t_REJECT nf_conntrack_ipv4 xt_tcpudp nf_defrag_ipv4 xt_state nf_conntrack_ipv6 nf_defrag_ipv6
>> xt_conntrack nf_conntrack iptable_mangle ip6table_raw ip6table_mangle nfnetlink ip6table_filter ip
>> 6_tables iptable_filter ip_tables x_tables ipmi_devintf ipmi_si ipmi_msghandler coretemp kvm_intel kvm ghash_clmulni_intel aesni_intel xts aes_x86_64
>> lrw gf128mul ablk_helper cryptd iTCO_wdt iTCO_vendor_support dcdbas microcode pcspkr jo
>> ydev lpc_ich shpchp hed evbug hid_generic usbhid hid ahci libahci megaraid_sas tg3 [last unloaded: drbd]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196368] Pid: 10942, comm: mysqld Tainted: G        W    3.7.2-vs2.3.5.5-rol-em64t #4
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196368] Call Trace:
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196370]  <IRQ> [<ffffffff81053bff>] warn_slowpath_common+0x7f/0xc0
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196371] [<ffffffff81594c52>] ? skb_release_data+0xf2/0x110
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196372] [<ffffffff81053c5a>] warn_slowpath_null+0x1a/0x20
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196373] [<ffffffff81594e9d>] skb_release_head_state+0xed/0x100
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196374] [<ffffffff81594c86>] __kfree_skb+0x16/0xa0
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196375] [<ffffffff8159521c>] consume_skb+0x2c/0x80
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196379] [<ffffffffa000b0af>] tg3_poll_work+0x5ef/0xdb0 [tg3]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196384] [<ffffffffa000b055>] ? tg3_poll_work+0x595/0xdb0 [tg3]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196388] [<ffffffffa00145cf>] tg3_poll+0x7f/0x390 [tg3]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196392] [<ffffffffa000b927>] ? tg3_poll_msix+0xb7/0x140 [tg3]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196394] [<ffffffff815b9622>] netpoll_poll_dev+0x162/0x580
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196395] [<ffffffff815b9bcc>] netpoll_send_skb_on_dev+0x18c/0x3a0
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196398] [<ffffffff815ba0f7>] netpoll_send_udp+0x277/0x290
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196400] [<ffffffffa03ae91f>] write_msg+0xaf/0x100 [netconsole]
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196401] [<ffffffff81054959>] call_console_drivers.constprop.16+0x99/0x100
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196403] [<ffffffff810553b9>] console_unlock+0x3d9/0x420
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196404] [<ffffffff81055ca5>] vprintk_emit+0x255/0x510
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196406] [<ffffffff8169f0b9>] printk+0x61/0x63
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196407] [<ffffffff81031e8e>] therm_throt_process+0x13e/0x180
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196408] [<ffffffff81032066>] intel_thermal_interrupt+0x196/0x1a0
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196410] [<ffffffff810320c1>] smp_thermal_interrupt+0x21/0x40
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196411] [<ffffffff816b1a1a>] thermal_interrupt+0x6a/0x70
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196413]  <EOI> [<ffffffff816b0e19>] ? system_call_fastpath+0x16/0x1b
>> Feb 20 15:58:04 dbhost04 kernel: [1463997.196414] ---[ end trace e3ec69533a534ff5 ]---
>> ...
>>
>> After the last message I got this entries in syslog, too:
>> Feb 20 15:58:04 dbhost04 kernel: [1464001.755218] CPU18: Core power limit normal
>> Feb 20 15:58:04 dbhost04 kernel: [1464001.760038] Clocksource tsc unstable (delta = 299966106527 ns)
>> Feb 20 15:58:04 dbhost04 kernel: [1464001.769627] Switching to clocksource hpet
>>
>> I searched the archives for this error, but I can't find any solution.
>> And my second PER620 doesn't show this error until now.
>>
>> Have you any idea what this problem could be?
>>
>> I'm not subscribed to lkml, if you need more information please contact me directly by email.
>>
>> Many thanks for your help.
>> Urban
>
> CC netdev
>
> I guess tg3 needs to call dev_kfree_skb_any()
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index bdb0869..22d9e44 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5942,7 +5942,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
>   		pkts_compl++;
>   		bytes_compl += skb->len;
>
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);
>
>   		if (unlikely(tx_bug)) {
>   			tg3_tx_recover(tp);
>
>
>
