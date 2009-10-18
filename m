From: Anirban Sinha <ani@anirban.org>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM enabled
Date: Sat, 17 Oct 2009 19:35:08 -0700
Message-ID: <4ADA7EDC.5010402@anirban.org>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local> <20091008.155429.02850661.davem@davemloft.net> <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local> <20091008.175703.83006470.davem@davemloft.net> <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Anirban Sinha <asinha@zeugmasystems.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f171.google.com ([209.85.216.171]:46676 "EHLO
	mail-px0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbZJRCky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 22:40:54 -0400
In-Reply-To: <Pine.LNX.4.64.0910171035340.2364@sleet.zeugmasystems.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Once upon a time, like on 09-10-17 10:57 AM, Anirban Sinha wrote:
> On Thu, 8 Oct 2009, David Miller wrote:
> 
>>>>> We are noticing a kernel OOPS on 2.6.26 kernel when we issue the command
>>>>> "clear ip bgp <bgp-peer-ip>" on Quagga BGP routing software.

and btw, this is the crash (on mips) we are talking about:

# [23:10:35.108808] Kernel bug detected[#1]:
[23:10:35.112527] Cpu 0
[23:10:35.114676] $ 0   : 0000000000000000 0000000014001fe0
0000000000000066 0000000000000004
[23:10:35.122845] $ 4   : ffffffff80516c10 0000000014001fe0
ffffffff8050c010 0000000000000004
[23:10:35.131015] $ 8   : 0000000000000000 0000000000000041
ffffffff805142e8 0000000000000001
[23:10:35.139184] $12   : ffffffff80600000 ffffffff805f0000
0000000000000064 0000000000000190
[23:10:35.147354] $16   : 0000000000000102 ffffffff803afdf0
ffffffff80539040 ffffffff80600780
[23:10:35.155526] $20   : ffffffff80540000 0000000000200200
ffffffff804c0000 000000000000000a
[23:10:35.163695] $24   : a3d70a3d70a3d70b 8000000000000003
[23:10:35.171865] $28   : ffffffff8050c000 ffffffff8050fd90
9000000010030000 ffffffff801487a8
[23:10:35.180035] Hi    : 0000000000000000
[23:10:35.183819] Lo    : 0000000000000000
[23:10:35.187603] epc   : ffffffff801487a8 run_timer_softirq+0x198/0x258
Tainted: P
[23:10:35.196032] ra    : ffffffff801487a8 run_timer_softirq+0x198/0x258
[23:10:35.202395] Status: 14001fe3    KX SX UX KERNEL EXL IE
[23:10:35.207814] Cause : 00808024
[23:10:35.210911] PrId  : 01041100 (SiByte SB1A)
[23:10:35.215209] Modules linked in: xt_state ipt_REJECT iptable_filter
nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
ip_tables ebtable_filter ebtables bridge llc zeug_ipmcdrv(P) irqdisp(P)
zvirt(P) zeugmod(P) softdog
[23:10:35.236024] Process swapper (pid: 0, threadinfo=ffffffff8050c000,
task=ffffffff805142e8, tls=0000000000000000)
[23:10:35.246169] Stack : ffffffff8050fd90 ffffffff8050fd90
0000000014001fe0 ffffffff805ff3e0
[23:10:35.254166]         ffffffff806003c4 0000000000000001
ffffffff8053f650 ffffffff805706d0
[23:10:35.262337]         ffffffff80572020 ffffffff80142280
ffffffff806003c0 0000000000000000
[23:10:35.270507]         0000000014001fe0 000000000000c5b0
ffffffff8fefc520 ffffffff8feea52c
[23:10:35.278676]         0000000000000015 0000000000004460
0000000000000940 ffffffff8fe1bf00
[23:10:35.286846]         ffffffff8fffdab0 ffffffff80142410
0000000000000000 ffffffff80142778
[23:10:35.295017]         ffffffff80103d20 ffffffff80103d20
0000000000000000 0000000014001fe1
[23:10:35.303187]         0000000000040000 ffffffff8050c010
0000000000000000 a80000017f87c138
[23:10:35.311357]         0000000014001fe0 ffffffffffff00fe
0000000000000004 a80000017e7e0680
[23:10:35.319528]         0000000000000000 000000000000001d
ffffffff8050ffe0 0000000000001f00
[23:10:35.327696]         ...
[23:10:35.330536] Call Trace:
[23:10:35.333201] [<ffffffff801487a8>] run_timer_softirq+0x198/0x258
[23:10:35.339224] [<ffffffff80142280>] __do_softirq+0x198/0x288
[23:10:35.344812] [<ffffffff80142410>] do_softirq+0xa0/0xa8
[23:10:35.350057] [<ffffffff80142778>] irq_exit+0x70/0x88
[23:10:35.355131] [<ffffffff80103d20>] ret_from_irq+0x0/0x4
[23:10:35.360377] [<ffffffff801063f4>] cpu_idle+0x1c/0x88
[23:10:35.365455]
[23:10:35.367171]
[23:10:35.367174] Code: 0040382d  0c04ef4c  00000000 <0200000d> 0c10ee9c
0260202d  dfa60000  17a6ffe5  00000000
[23:10:35.378822] Kernel panic - not syncing: Fatal exception in
interrupt

