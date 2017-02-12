From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 4.9.4 panic, nf_conntrack_tuple_taken
Date: Sun, 12 Feb 2017 13:21:43 +0200
Message-ID: <377a6474bc6b304c7207aec2a4cd0f6f@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:59730 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdBLLVq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 06:21:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Seems i'm quite "lucky" and hitting another bug.
This time it is different server, but i believe i've seen this bug on 
few pppoe servers, but here it is happening once per 1-2 days.

Out of tree patch applied, to optimize gc heuristics. I don't exclude 
(but very small chance) hardware issue, and this bug very hard to call 
trace/panic message,
i dont know why, but it was not storing it in pstore, and once stored 
only half of message.
It happens on 4.9.9 as well, but didnt captured call trace yet, if it is 
same or not, this is only one trace i was able to catch.
Also might be related to fragmentation/tunnels, because reboots started 
when i ran ipip ddos protection tunnel.

<4>[160340.861244] general protection fault: 0000 [#1] SMP
<4>[160340.861527] Modules linked in: ioatdma w83l786ng w83l785ts w83795 
w83793 w83792d w83791d w83781d w83627ehf vt8231 via686a tmp421 tmp401 
tmp102 thmc50 tc74 smsc47m192 smm665 sis5595 sht21 sht15 pmbus_core 
pcf8591 ntc_thermistor nct7904 nct7802 nct6775 mcp3021 max6697 max6650 
max6642 max6639 max31790 max197 max1668 max1619 max16065 max1111 ltc4261 
ltc4245 ltc4215 ltc4151 ltc2990 lm95245 lm95241 lm95234 lm93 lm92 lm90 
lm87 lm85 lm83 lm80 lm78 lm77 lm75 lm73 lm70 lm63 lineage_pem k8temp 
k10temp jc42 ina3221 ina2xx ina209 ibmpex ibmaem i5k_amb i5500_temp 
hwmon_vid hih6130 gpio_fan gl518sm g760a ftsteutates fschmd fam15h_power 
f75375s emc6w201 emc2103 emc1403 ds620 ds1621 coretemp asus_atk0110 
asc7621 amc6821 adt7x10 adt7470 adt7462 adt7411 ads7871 ads7828 ads1015 
adm1031 adm1029 adm1021 adcxx ad7418 ad7414
<4>[160340.870563]  ad7314 acpi_power_meter cls_u32 sch_pie sch_htb msr 
ipmi_devintf ipmi_si ipmi_msghandler xt_nat xt_set xt_mark xt_connmark 
iptable_raw xt_CT ip_set_hash_net ip_set nfnetlink xt_hl xt_TCPMSS 
xt_tcpudp nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp 
nf_conntrack_proto_gre iptable_filter iptable_nat nf_conntrack_ipv4 
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle ip_tables 
x_tables netconsole configfs ipip tunnel4 ip_tunnel 8021q garp mrp stp 
llc ixgbe dca
<4>[160340.875258] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 
4.9.4-build-0130 #4
<4>[160340.875529] Hardware name: Supermicro X10SLM+-LN4F/X10SLM+-LN4F, 
BIOS 3.0a 12/17/2015
<4>[160340.875981] task: ffff88040d5bd5c0 task.stack: ffffc90001940000
<4>[160340.876247] RIP: 0010:[<ffffffffa009b60b>]  [<ffffffffa009b60b>] 
nf_conntrack_tuple_taken+0x68/0x196 [nf_conntrack]
<4>[160340.876789] RSP: 0018:ffff88041fdc37c0  EFLAGS: 00010246
<4>[160340.877053] RAX: 0000000002530d1f RBX: ffb00404024062c8 RCX: 
0000000000000001
<4>[160340.877506] RDX: 0000000000001f2f RSI: 00000000f3476b40 RDI: 
ffff8803f9542640
<4>[160340.877956] RBP: ffff88041fdc37f0 R08: 000000002682c87d R09: 
000000005bf0500a
<4>[160340.878410] R10: 00000000001e6b01 R11: 000000003a8b60eb R12: 
ffff88041fdc3800
<4>[160340.878860] R13: 0000000000004aeb R14: ffff880407304780 R15: 
ffffffff820b2dc0
<4>[160340.879315] FS:  0000000000000000(0000) GS:ffff88041fdc0000(0000) 
knlGS:0000000000000000
<4>[160340.879771] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[160340.880036] CR2: 000000000062da00 CR3: 0000000002007000 CR4: 
00000000001406e0
<4>[160340.880483] Stack:
<4>[160340.880743]  ffff880407280000 ffff880407304780 ffff880407304780 
0000000000000000
<4>[160340.881472]  0000000000000008 00000000001e6b01 ffff88041fdc3830 
ffffffffa00b8209
<4>[160340.882197]  00000000fa50655f 0000000000000000 0e50f05b0002bb01 
0000000000000000
<4>[160340.882930] Call Trace:
<4>[160340.883185]  <IRQ>
<4>[160340.883264]  [<ffffffffa00b8209>] nf_nat_used_tuple+0x24/0x2b 
[nf_nat]
<4>[160340.883789]  [<ffffffffa00b8ba8>] nf_nat_setup_info+0x2bf/0x805 
[nf_nat]
<4>[160340.884062]  [<ffffffffa00b80cd>] ? 
nf_nat_bysource_hash+0xb0/0xb0 [nf_nat]
<4>[160340.884331]  [<ffffffffa0124092>] xt_snat_target_v0+0x65/0x67 
[xt_nat]
<4>[160340.884599]  [<ffffffffa008e3d3>] ipt_do_table+0x28e/0x5a2 
[ip_tables]
<4>[160340.884868]  [<ffffffffa008e6cb>] ? ipt_do_table+0x586/0x5a2 
[ip_tables]
<4>[160340.885135]  [<ffffffffa00cf040>] ? iptable_nat_ipv4_fn+0x12/0x12 
[iptable_nat]
<4>[160340.890247]  [<ffffffffa00cf05a>] iptable_nat_do_chain+0x1a/0x1c 
[iptable_nat]
<4>[160340.890701]  [<ffffffffa00c04e3>] nf_nat_ipv4_fn+0xeb/0x177 
[nf_nat_ipv4]
<4>[160340.890970]  [<ffffffffa00c0613>] nf_nat_ipv4_out+0x35/0x37 
[nf_nat_ipv4]
<4>[160340.891239]  [<ffffffffa00cf07e>] iptable_nat_ipv4_out+0x10/0x12 
[iptable_nat]
<4>[160340.891697]  [<ffffffff818c13e9>] nf_iterate+0x34/0x57
<4>[160340.891960]  [<ffffffff818c1437>] nf_hook_slow+0x2b/0x91
<4>[160340.892224]  [<ffffffff818cb0c4>] ip_output+0x99/0xb6
<4>[160340.892493]  [<ffffffff818ca6d5>] ? 
ip_fragment.constprop.5+0x77/0x77
<4>[160340.892766]  [<ffffffff818c8007>] ip_forward_finish+0x53/0x58
<4>[160340.893034]  [<ffffffff818c8339>] ip_forward+0x32d/0x33a
<4>[160340.893296]  [<ffffffff818c7fb4>] ? ip_frag_mem+0x3e/0x3e
<4>[160340.893563]  [<ffffffff818c69b8>] ip_rcv_finish+0x2e8/0x2f3
<4>[160340.893828]  [<ffffffff818c6e93>] ip_rcv+0x318/0x325
<4>[160340.894095]  [<ffffffff818c66d0>] ? 
ip_local_deliver_finish+0x109/0x109
<4>[160340.894365]  [<ffffffff81895377>] 
__netif_receive_skb_core+0x5cf/0x807
<4>[160340.894631]  [<ffffffff818e97d2>] ? tcp4_gro_receive+0x17b/0x17f
<4>[160340.894902]  [<ffffffff818f5fe8>] ? inet_gro_receive+0x229/0x239
<4>[160340.895170]  [<ffffffff81895e1d>] __netif_receive_skb+0x13/0x55
<4>[160340.895439]  [<ffffffff81895e9a>] 
netif_receive_skb_internal+0x3b/0x70
<4>[160340.895706]  [<ffffffff81896785>] napi_gro_receive+0x45/0xab
<4>[160340.895974]  [<ffffffffa00095b5>] ixgbe_clean_rx_irq+0x8ac/0x924 
[ixgbe]
<4>[160340.896248]  [<ffffffffa000a23a>] ixgbe_poll+0x4ef/0x679 [ixgbe]
<4>[160340.896516]  [<ffffffff81896b6e>] net_rx_action+0x107/0x27d
<4>[160340.896781]  [<ffffffff810d18cc>] __do_softirq+0xb5/0x1a3
<4>[160340.897046]  [<ffffffff810d1b31>] irq_exit+0x4d/0x8e
<4>[160340.897315]  [<ffffffff81016bb7>] do_IRQ+0xaa/0xc2
<4>[160340.897581]  [<ffffffff8191487c>] common_interrupt+0x7c/0x7c
<4>[160340.897850]  <EOI>
<4>[160340.897925]  [<ffffffff81913976>] ? mwait_idle+0x4e/0x61
<4>[160340.898444]  [<ffffffff8101cb40>] arch_cpu_idle+0xa/0xc
<4>[160340.898713]  [<ffffffff81913a8b>] default_idle_call+0x20/0x22
<4>[160340.898979]  [<ffffffff810fa1a9>] cpu_startup_entry+0xde/0x185
<4>[160340.899247]  [<ffffffff8102bda3>] start_secondary+0xe8/0xeb
<4>[160340.899512] Code: 9f 00 00 75 d9 4c 89 fe 4c 89 e7 e8 24 ec ff ff 
41 89 c5 4c 0f af eb 49 c1 ed 20 48 8b 4d d0 4a 8d 04 e9 48 8b 18 f6 c3 
01 75 74 <0f> b6 43 37 48 89 df 48 89 c1 48 6b c0 38 48 83 c0 10 48 29 
c7
<1>[160340.904652] RIP  [<ffffffffa009b60b>] 
nf_conntrack_tuple_taken+0x68/0x196 [nf_conntrack]
<4>[160340.905189]  RSP <ffff88041fdc37c0>
<4>[160340.905455] ---[ end trace 568b38f07d199b72 ]---
<0>[160340.931057] Kernel panic - not syncing: Fatal exception in 
interrupt
<0>[160341.055391] Kernel Offset: disabled
