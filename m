From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: network card doesn't recovered itself after a SYN flooding attack
Date: Mon, 23 Nov 2015 10:54:16 +0100
Message-ID: <5652E248.2030802@iogearbox.net>
References: <56519E2B.8050500@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?windows-1252?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: romieu@fr.zoreil.com, vinschen@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56519E2B.8050500@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ cc'ing netdev and r8169 folks ]

On 11/22/2015 11:51 AM, Toralf F=F6rster wrote:
> At 22th of November at 21:26 UTC my server (64 bit stable Gentoo hard=
ened) suffered from a DDoS attack.
>
>  From the kern.log:
>
> =09
> Nov 20 22:26:29 tor-relay kernel: [2431358.124515] TCP: request_sock_=
TCP: Possible SYN flooding on port 80. Sending cookies.  Check SNMP cou=
nters.
> Nov 20 22:26:48 tor-relay kernel: [2431377.216133] ------------[ cut =
here ]------------
> Nov 20 22:26:48 tor-relay kernel: [2431377.216141] WARNING: CPU: 7 PI=
D: 12421 at net/sched/sch_generic.c:303 dev_watchdog+0x272/0x280()
> Nov 20 22:26:48 tor-relay kernel: [2431377.216143] NETDEV WATCHDOG: e=
np3s0 (r8169): transmit queue 0 timed out
> Nov 20 22:26:48 tor-relay kernel: [2431377.216145] Modules linked in:
> Nov 20 22:26:48 tor-relay kernel: [2431377.216148]  af_packet nf_log_=
ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_log=
_ipv4 nf_log_common xt_LOG xt_multiport nf_conntrack_ipv4 nf_defrag_ipv=
4 xt_conntrack nf_conntrack iptable_filter ip_tables i2c_i801 i2c_core =
tpm_tis tpm thermal processor battery atkbd x86_pkg_temp_thermal button=
 microcode fan
> Nov 20 22:26:48 tor-relay kernel: [2431377.216173] CPU: 7 PID: 12421 =
Comm: emerge Not tainted 4.1.7-hardened-r1 #1
> Nov 20 22:26:48 tor-relay kernel: [2431377.216174] Hardware name: Sys=
tem manufacturer System Product Name/P8H77-M PRO, BIOS 0922 09/10/2012
> Nov 20 22:26:48 tor-relay kernel: [2431377.216176]  ffffffff994fa966 =
0000000000000000 ffffffff99bced09 ffff88041fbc3d18
> Nov 20 22:26:48 tor-relay kernel: [2431377.216179]  ffffffff99983e26 =
0000000000000000 ffff88041fbc3d68 ffff88041fbc3d58
> Nov 20 22:26:48 tor-relay kernel: [2431377.216182]  ffffffff9947f08a =
ffff88041fbc3d48 ffffffff99bced09 000000000000012f
> Nov 20 22:26:48 tor-relay kernel: [2431377.216185] Call Trace:
> Nov 20 22:26:48 tor-relay kernel: [2431377.216187]    [] ? print_modu=
les+0x76/0xe0
> Nov 20 22:26:48 tor-relay kernel: [2431377.216198]  [] dump_stack+0x4=
5/0x5d
> Nov 20 22:26:48 tor-relay kernel: [2431377.216203]  [] warn_slowpath_=
common+0x8a/0xd0
> Nov 20 22:26:48 tor-relay kernel: [2431377.216205]  [] warn_slowpath_=
fmt+0x5a/0x70
> Nov 20 22:26:48 tor-relay kernel: [2431377.216210]  [] ? task_tick_fa=
ir+0x2a8/0x760
> Nov 20 22:26:48 tor-relay kernel: [2431377.216213]  [] dev_watchdog+0=
x272/0x280
> Nov 20 22:26:48 tor-relay kernel: [2431377.216216]  [] ? dev_deactiva=
te_queue+0x70/0x70
> Nov 20 22:26:48 tor-relay kernel: [2431377.216219]  [] call_timer_fn+=
0x47/0x140
> Nov 20 22:26:48 tor-relay kernel: [2431377.216222]  [] run_timer_soft=
irq+0x291/0x450
> Nov 20 22:26:48 tor-relay kernel: [2431377.216224]  [] ? dev_deactiva=
te_queue+0x70/0x70
> Nov 20 22:26:48 tor-relay kernel: [2431377.216228]  [] __do_softirq+0=
xf8/0x290
> Nov 20 22:26:48 tor-relay kernel: [2431377.216230]  [] irq_exit+0x9d/=
0xb0
> Nov 20 22:26:48 tor-relay kernel: [2431377.216235]  [] smp_apic_timer=
_interrupt+0x55/0x70
> Nov 20 22:26:48 tor-relay kernel: [2431377.216237]  [] apic_timer_int=
errupt+0x97/0xa0
> Nov 20 22:26:48 tor-relay kernel: [2431377.216239]
> Nov 20 22:26:48 tor-relay kernel: [2431377.216241] ---[ end trace 934=
31a9382c0a11a ]---
> Nov 20 22:26:48 tor-relay kernel: [2431377.237826] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:28:18 tor-relay kernel: [2431467.175659] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:28:30 tor-relay kernel: [2431479.172562] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:28:42 tor-relay kernel: [2431491.164472] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:28:54 tor-relay kernel: [2431503.170416] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:29:06 tor-relay kernel: [2431515.148333] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:29:18 tor-relay kernel: [2431527.143293] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:29:30 tor-relay kernel: [2431539.142164] r8169 0000:03:00.0=
 enp3s0: link up
> Nov 20 22:29:42 tor-relay kernel: [2431551.124104] r8169 0000:03:00.0=
 enp3s0: link up
> ...
> Nov 22 10:56:24 tor-relay kernel: [2562675.624512] r8169 0000:03:00.0=
 enp3s0: link up
>
>
>
> The last line repeated and the network was down till I initiated a ha=
rdware reset.
>
> It looks for me that the attack turned the network card into a state =
from which it couldn't recovered itself, or ?
> Anything what I should change here at the system to avoid such a hang=
 ?
>
