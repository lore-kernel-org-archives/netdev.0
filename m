From: canqun zhang <canqunzhang@gmail.com>
Subject: Re: kernel panic when running /etc/init.d/iptables restart
Date: Tue, 25 Dec 2012 15:25:11 +0800
Message-ID: <CAFFEFTULzSysz+JCBC==VtKD8u1KO6EZnSdQ5XWM7um-zs9_pg@mail.gmail.com>
References: <CAFFEFTXxsPRf1Rmxyih0wL4O6q8G0OFmz0iRLX0tOYedYfajHw@mail.gmail.com>
	<50D93B43.8060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50D93B43.8060303@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gao feng
The stack information is as follows. The kenel will panic because the
nf_ct_destroy is NULL.

Reproduction:
(1) starting a lxc container
(2) iptables -t nat -A POSTROUTING -s 10.48.254.18 -o eth1 -j
MASQUERADE (run it on host machine)
(3) /etc/ini.d/iptables save (run it on host machine)
(4)/etc/init.d/iptables restart (run it on host machine)

Stack:
Pid: 0, comm: swapper Not tainted 2.6.32-279.14.1.rc3.el6.x86_64 #1
IBM System x3650 M4 -[7915IA4]-/00J6528
RIP: 0010:[<ffffffff81466949>]  [<ffffffff81466949>]
nf_conntrack_destroy+0x19/0x30
RSP: 0018:ffff880028303ab0  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff881051b237c0 RCX: 00000000000000d4
RDX: 0000000000000500 RSI: 0000000000000000 RDI: ffff881056bc0528
RBP: ffff880028303ab0 R08: ffff8810514fc020 R09: ffff8810574b6110
R10: 0000000000000000 R11: 0000000000000004 R12: ffffffff814445fe
R13: ffff88105327fba8 R14: ffff882059ed6e00 R15: 0000000000000000
=46S:  0000000000000000(0000) GS:ffff880028300000(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f3484002098 CR3: 0000002056792000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff8810590b2000, task ffff88205954=
c040)
Stack:
 ffff880028303ad0 ffffffff8142febd ffff880028303b30 ffff881051b237c0
<d> ffff880028303af0 ffffffff8142fc36 0000000200000004 ffff881051b237c0
<d> ffff880028303b20 ffffffff8142fd82 ffff880028303b20 ffff882059ed6d80
Call Trace:
 <IRQ>
 [<ffffffff8142febd>] skb_release_head_state+0xed/0x110
 [<ffffffff8142fc36>] __kfree_skb+0x16/0xa0
 [<ffffffff8142fd82>] kfree_skb+0x42/0x90
 [<ffffffff814445fe>] __neigh_event_send+0x11e/0x1e0
 [<ffffffff814447f3>] neigh_resolve_output+0x133/0x370
 [<ffffffff81054d55>] ? select_idle_sibling+0x95/0x150
 [<ffffffff814774b7>] ip_finish_output+0x237/0x310
 [<ffffffff81477648>] ip_output+0xb8/0xc0
 [<ffffffff81476945>] ip_local_out+0x25/0x30
 [<ffffffff81476e20>] ip_queue_xmit+0x190/0x420
 [<ffffffff8106012c>] ? try_to_wake_up+0x24c/0x3e0
 [<ffffffff8148bbae>] tcp_transmit_skb+0x3fe/0x7b0
 [<ffffffff8148cfda>] tcp_retransmit_skb+0x1ba/0x5f0
 [<ffffffff81053463>] ? __wake_up+0x53/0x70
 [<ffffffff8148fd00>] ? tcp_write_timer+0x0/0x200
 [<ffffffff8148f85f>] tcp_retransmit_timer+0x1df/0x680
 [<ffffffff8148fe98>] tcp_write_timer+0x198/0x200
 [<ffffffff8107e907>] run_timer_softirq+0x197/0x340
 [<ffffffff810a2350>] ? tick_sched_timer+0x0/0xc0
 [<ffffffff8102b40d>] ? lapic_next_event+0x1d/0x30
 [<ffffffff81073f31>] __do_softirq+0xc1/0x1e0
 [<ffffffff81096d30>] ? hrtimer_interrupt+0x140/0x250
 [<ffffffff8100c24c>] call_softirq+0x1c/0x30
 [<ffffffff8100de85>] do_softirq+0x65/0xa0
 [<ffffffff81073d15>] irq_exit+0x85/0x90
 [<ffffffff81506050>] smp_apic_timer_interrupt+0x70/0x9b
 [<ffffffff8100bc13>] apic_timer_interrupt+0x13/0x20
 <EOI>
 [<ffffffff812cd9ae>] ? intel_idle+0xde/0x170
 [<ffffffff812cd991>] ? intel_idle+0xc1/0x170
 [<ffffffff8109922d>] ? sched_clock_cpu+0xcd/0x110
 [<ffffffff81407827>] cpuidle_idle_call+0xa7/0x140
 [<ffffffff81009e06>] cpu_idle+0xb6/0x110
 [<ffffffff814f714f>] start_secondary+0x22a/0x26d
Code: 02 ff d0 c9 c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89
e5 0f 1f 44 00 00 48 8b 05 90 7c ba 00 48 85 c0 74 04 ff d0 c9 c3 <0f>
0b 0f 1f 44 00 00 eb f9 66 66 66 66 66
2e 0f 1f 84 00 00 00

2012/12/25 Gao feng <gaofeng@cn.fujitsu.com>:
> cc netdev
> Hi canqun:
>
> On 2012/12/24 13:51, canqun zhang wrote:
>> Hi Patrick=A3=AC
>> If i start  one lxc container instance, and then in the system there
>> will be two net namespaces,one is init_net namespace, the other is
>> created by lxc.If running "/etc/init.d/iptables restart",the system
>> will be panic. I find iptables restarting will clean init_net
>> namespace firstly,then clean the net namespace created by lxc,buf
>> related functions about cleaning up init_net namespace will destroy
>> global variables such as nf_ct_destroy,ip_ct_attach=A3=ACetc.So,funt=
ions
>> cleaning up  the other net namespace will be panic.
>>
>
> I'm afraid that the system will not panic.
> When do rmmod nf_conntrack_ipv[4,6],we already call nf_ct_iterate_cle=
anup
> to destroy the nf_conns which belongs to l[3,4]proto  protocols,At th=
is
> time the nf_ct_destroy still points to destroy_conntrack because the =
module
> nf_conntrack is hold by l3 and l4proto.
> You can check the function nf_conntrack_l[3,4]proto_unregister.
>
> Can you make it a little clear?
> The reproduction and oops dump stack is useful.
>
> Thanks!
