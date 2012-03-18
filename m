From: Joseph Glanville <joseph.glanville-2MxvZkOi9dvvnOemgxGiVw@public.gmane.org>
Subject: Re: Kernel Panic with bonding + IPoIB on 3.2.9
Date: Mon, 19 Mar 2012 08:20:45 +1100
Message-ID: <CAOzFzEixUc-9Xs_eE4AKZbUgotvTVX4aFMinGViK2uG8+cRXMg@mail.gmail.com>
References: <CAOzFzEiufg40gKBH6D7zeB47SebfPvgzqOLxhF5eQqpYd-r4zQ@mail.gmail.com>
	<CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAOzFzEi=UOnwiV+qVks7+RnYU3PFbaQ+3OaEE3YFG2HHuD5ydQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19 March 2012 07:21, Joseph Glanville
<joseph.glanville-2MxvZkOi9dvvnOemgxGiVw@public.gmane.org> wrote:
> On 19 March 2012 06:41, Joseph Glanville
> <joseph.glanville-2MxvZkOi9dvvnOemgxGiVw@public.gmane.org> wrote:
>> Hi guys,
>>
>> I am getting an annoying kernel panic on 3.2.9 that seems to be
>> related to bonding (as I can't reproduce the crash without it)
>> I believe it might be related to LRO/GRO but there isnt a param to
>> disable it anymore that I could see in /ulp/ipoib/
>> Let me know if there is anything further I can do to help debug.
>>
>> Useful information:
>>
>> Hardware:
>> Dell C2100 - Intel Xeon dual socket with 144GB RAM
>> Mellanox Connect-X DDR using in kernel mlx4 driver
>> Machine is also a Xen dom0
>>
>> ibstatCA 'mlx4_0'
>> =A0 =A0 =A0 =A0CA type: MT26418
>> =A0 =A0 =A0 =A0Number of ports: 2
>> =A0 =A0 =A0 =A0Firmware version: 2.9.1000
>> =A0 =A0 =A0 =A0Hardware version: a0
>> =A0 =A0 =A0 =A0Node GUID: 0x0002c9030008d7be
>> =A0 =A0 =A0 =A0System image GUID: 0x0002c9030008d7c1
>> =A0 =A0 =A0 =A0Port 1:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0State: Active
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Physical state: LinkUp
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Rate: 20
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Base lid: 6
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LMC: 0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SM lid: 1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Capability mask: 0x02590868
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Port GUID: 0x0002c9030008d7bf
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Link layer: InfiniBand
>> =A0 =A0 =A0 =A0Port 2:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0State: Active
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Physical state: LinkUp
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Rate: 20
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Base lid: 9
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LMC: 0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SM lid: 1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Capability mask: 0x02590868
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Port GUID: 0x0002c9030008d7c0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Link layer: InfiniBand
>>
>>
>> ip link show
>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>> =A0 =A0link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> 2: ib0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 65220 qdisc
>> pfifo_fast master bond0 state UP qlen 256
>> =A0 =A0link/infiniband
>> 80:00:00:48:fe:80:00:00:00:00:00:00:00:02:c9:03:00:08:d7:bf brd
>> 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
>> 3: ib1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 65220 qdisc
>> pfifo_fast master bond0 state UP qlen 256
>> =A0 =A0link/infiniband
>> 80:00:00:49:fe:80:00:00:00:00:00:00:00:02:c9:03:00:08:d7:c0 brd
>> 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
>> 4: gre0: <NOARP> mtu 1476 qdisc noop state DOWN
>> =A0 =A0link/gre 0.0.0.0 brd 0.0.0.0
>> 5: sit0: <NOARP> mtu 1480 qdisc noop state DOWN
>> =A0 =A0link/sit 0.0.0.0 brd 0.0.0.0
>> 6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 65220 qdisc
>> noqueue state UP
>> =A0 =A0link/infiniband
>> 80:00:00:48:fe:80:00:00:00:00:00:00:00:02:c9:03:00:08:d7:bf brd
>> 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:f
>>
>> The KP itself:
>> [ =A0422.046837] ------------[ cut here ]------------
>> [ =A0422.047024] kernel BUG at net/core/dev.c:1896!
>> [ =A0422.047126] invalid opcode: 0000 [#1] SMP
>> [ =A0422.047289] CPU 1
>> [ =A0422.047328] Modules linked in: ib_srpt(O) scst_vdisk(O) scst(O)
>> bonding raid1 raid0 md_mod dm_multipath
>> [ =A0422.047869]
>> [ =A0422.047962] Pid: 3352, comm: sshd Tainted: G =A0 =A0 =A0 =A0 =A0=
 O
>> 3.2.1-orion #4 Dell =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PowerEdge C2=
100 =A0 =A0 =A0 /0P19C9
>> [ =A0422.048237] RIP: e030:[<ffffffff81559b92>] =A0[<ffffffff81559b9=
2>]
>> skb_checksum_help+0x142/0x150
>> [ =A0422.048450] RSP: e02b:ffff88006cb11758 =A0EFLAGS: 00010282
>> [ =A0422.048556] RAX: 0000000000000108 RBX: ffff880072f7f4e8 RCX: 00=
00000060004420
>> [ =A0422.048668] RDX: 0000000000000108 RSI: 0000000000000000 RDI: ff=
ff880072f7f4e8
>> [ =A0422.048780] RBP: ffff88006cb11778 R08: ffff88000e53529c R09: 00=
00000000000104
>> [ =A0422.048892] R10: ffffffff8151a7d0 R11: 0000000000000000 R12: 00=
000000ffff0018
>> [ =A0422.049005] R13: 0000000000000000 R14: 0000000000000000 R15: 00=
00000000000000
>> [ =A0422.049119] FS: =A000007fea22aa8700(0000) GS:ffff8800bf435000(0=
000)
>> knlGS:0000000000000000
>> [ =A0422.049288] CS: =A0e033 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ =A0422.049395] CR2: 00007fff14d07ed8 CR3: 00000000085dc000 CR4: 00=
00000000002660
>> [ =A0422.049506] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00=
00000000000000
>> [ =A0422.049618] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00=
00000000000400
>> [ =A0422.049742] Process sshd (pid: 3352, threadinfo ffff88006cb1000=
0,
>> task ffff88000cea4920)
>> [ =A0422.049909] Stack:
>> [ =A0422.050002] =A0ffff880072f7f4e8 ffff88000ce64000 00000000000000=
00
>> 0000000000000000
>> [ =A0422.050290] =A0ffff88006cb117e8 ffffffff8155f15e ffff88006cb118=
58
>> ffffffff8187ba80
>> [ =A0422.050580] =A0ffff88000ce5bc80 0000000000000000 00000000000000=
06
>> 0000000000000000
>> [ =A0422.050869] Call Trace:
>> [ =A0422.050967] =A0[<ffffffff8155f15e>] dev_hard_start_xmit+0x36e/0=
x6c0
>> [ =A0422.051084] =A0[<ffffffff8157a19b>] sch_direct_xmit+0xdb/0x1e0
>> [ =A0422.051191] =A0[<ffffffff8155f638>] dev_queue_xmit+0x188/0x620
>> [ =A0422.051301] =A0[<ffffffffa003b297>] bond_dev_queue_xmit+0x27/0x=
70 [bonding]
>> [ =A0422.051413] =A0[<ffffffffa003b5e4>] bond_start_xmit+0x304/0x4e0=
 [bonding]
>> [ =A0422.051524] =A0[<ffffffff8155f099>] dev_hard_start_xmit+0x2a9/0=
x6c0
>> [ =A0422.051633] =A0[<ffffffff8155f895>] dev_queue_xmit+0x3e5/0x620
>> [ =A0422.051742] =A0[<ffffffff81567cbd>] neigh_connected_output+0xbd=
/0xf0
>> [ =A0422.051853] =A0[<ffffffff815a7120>] ? ip_fragment+0x850/0x850
>> [ =A0422.051960] =A0[<ffffffff815a72ae>] ip_finish_output+0x18e/0x30=
0
>> [ =A0422.052068] =A0[<ffffffff815a7dd8>] ip_output+0x98/0xa0
>> [ =A0422.052172] =A0[<ffffffff815a74be>] ? __ip_local_out+0x9e/0xa0
>> [ =A0422.052279] =A0[<ffffffff815a74e4>] ip_local_out+0x24/0x30
>> [ =A0422.052385] =A0[<ffffffff815a764a>] ip_queue_xmit+0x15a/0x400
>> [ =A0422.052510] =A0[<ffffffff815bdade>] tcp_transmit_skb+0x3de/0x8f=
0
>> [ =A0422.052617] =A0[<ffffffff815be702>] tcp_write_xmit+0x1d2/0x9c0
>> [ =A0422.052725] =A0[<ffffffff81129057>] ? ksize+0x17/0xc0
>> [ =A0422.052829] =A0[<ffffffff815bef41>] __tcp_push_pending_frames+0=
x21/0x90
>> [ =A0422.052939] =A0[<ffffffff815b09ae>] tcp_sendmsg+0x75e/0xd80
>> [ =A0422.053047] =A0[<ffffffff815d4c0f>] inet_sendmsg+0x5f/0xb0
>> [ =A0422.053155] =A0[<ffffffff81009f3f>] ? xen_restore_fl_direct_rel=
oc+0x4/0x4
>> [ =A0422.053267] =A0[<ffffffff8126734e>] ? selinux_socket_sendmsg+0x=
1e/0x20
>> [ =A0422.053377] =A0[<ffffffff8154732a>] sock_aio_write+0x15a/0x170
>> [ =A0422.053486] =A0[<ffffffff812652d1>] ? inode_has_perm.clone.15+0=
x21/0x30
>> [ =A0422.053597] =A0[<ffffffff8113133a>] do_sync_write+0xda/0x120
>> [ =A0422.053704] =A0[<ffffffff81268003>] ? selinux_file_permission+0=
xb3/0x140
>> [ =A0422.053821] =A0[<ffffffff812e8efa>] ? put_ldisc+0x5a/0xc0
>> [ =A0422.053937] =A0[<ffffffff81262237>] ? security_file_permission+=
0x27/0xb0
>> [ =A0422.054048] =A0[<ffffffff81131ca9>] vfs_write+0x169/0x180
>> [ =A0422.054153] =A0[<ffffffff81131f1c>] sys_write+0x4c/0x90
>> [ =A0422.054260] =A0[<ffffffff816891d2>] system_call_fastpath+0x16/0=
x1b
>> [ =A0422.054367] Code: 65 86 ff ff 85 c0 0f 84 75 ff ff ff eb a6 41 =
29
>> d4 48 8b 83 d8 00 00 00 0f b7 53 72 45 8d 64 04 02 41 39 d4 77 cd e9
>> 5d ff ff ff <0f> 0b 0f 0b 66 2e 0f 1f 84 00 00 00 00 00 55 b8 ea ff =
ff
>> ff 48
>> [ =A0422.056691] RIP =A0[<ffffffff81559b92>] skb_checksum_help+0x142=
/0x150
>> [ =A0422.056831] =A0RSP <ffff88006cb11758>
>> [ =A0422.056930] ---[ end trace 751906f8ee2b0c91 ]---
>> [ =A0422.057032] Kernel panic - not syncing: Fatal exception in inte=
rrupt
>> [ =A0422.057141] Pid: 3352, comm: sshd Tainted: G =A0 =A0 =A0D =A0 =A0=
O 3.2.1-orion #4
>> [ =A0422.057250] Call Trace:
>> [ =A0422.057348] =A0[<ffffffff8167e944>] panic+0x8c/0x1a0
>> [ =A0422.057451] =A0[<ffffffff816825fa>] oops_end+0xea/0xf0
>> [ =A0422.057557] =A0[<ffffffff81016636>] die+0x56/0x90
>> [ =A0422.057660] =A0[<ffffffff81681f64>] do_trap+0xc4/0x170
>> [ =A0422.057764] =A0[<ffffffff81013e50>] do_invalid_op+0x90/0xb0
>> [ =A0422.057870] =A0[<ffffffff81559b92>] ? skb_checksum_help+0x142/0=
x150
>> [ =A0422.057989] =A0[<ffffffff8168b1ab>] invalid_op+0x1b/0x20
>> [ =A0422.058101] =A0[<ffffffff8151a7d0>] ? ipoib_setup+0x330/0x330
>> [ =A0422.058207] =A0[<ffffffff81559b92>] ? skb_checksum_help+0x142/0=
x150
>> [ =A0422.058316] =A0[<ffffffff8155f15e>] dev_hard_start_xmit+0x36e/0=
x6c0
>> [ =A0422.058425] =A0[<ffffffff8157a19b>] sch_direct_xmit+0xdb/0x1e0
>> [ =A0422.058533] =A0[<ffffffff8155f638>] dev_queue_xmit+0x188/0x620
>> [ =A0422.058641] =A0[<ffffffffa003b297>] bond_dev_queue_xmit+0x27/0x=
70 [bonding]
>> [ =A0422.058753] =A0[<ffffffffa003b5e4>] bond_start_xmit+0x304/0x4e0=
 [bonding]
>> [ =A0422.058864] =A0[<ffffffff8155f099>] dev_hard_start_xmit+0x2a9/0=
x6c0
>> [ =A0422.058973] =A0[<ffffffff8155f895>] dev_queue_xmit+0x3e5/0x620
>> [ =A0422.059080] =A0[<ffffffff81567cbd>] neigh_connected_output+0xbd=
/0xf0
>> [ =A0422.059190] =A0[<ffffffff815a7120>] ? ip_fragment+0x850/0x850
>> [ =A0422.059296] =A0[<ffffffff815a72ae>] ip_finish_output+0x18e/0x30=
0
>> [ =A0422.059412] =A0[<ffffffff815a7dd8>] ip_output+0x98/0xa0
>> [ =A0422.059517] =A0[<ffffffff815a74be>] ? __ip_local_out+0x9e/0xa0
>> [ =A0422.059624] =A0[<ffffffff815a74e4>] ip_local_out+0x24/0x30
>> [ =A0422.059730] =A0[<ffffffff815a764a>] ip_queue_xmit+0x15a/0x400
>> [ =A0422.059836] =A0[<ffffffff815bdade>] tcp_transmit_skb+0x3de/0x8f=
0
>> [ =A0422.059944] =A0[<ffffffff815be702>] tcp_write_xmit+0x1d2/0x9c0
>>
>> --
>> Founder | Director | VP Research
>> Orion Virtualisation Solutions=A0|=A0www.orionvm.com.au=A0| Phone: 1=
300 56
>> 99 52 | Mobile: 0428 754 846
>
> CC'ing netdev as that is probably the most appropriate now that I
> think about it.
>
> --
> Founder | Director | VP Research
> Orion Virtualisation Solutions=A0|=A0www.orionvm.com.au=A0| Phone: 13=
00 56
> 99 52 | Mobile: 0428 754 846

I have narrowed it down to mtu, MTU up to 50k seems to work just fine,
but max MTU of 65520 basically instantly KPs the machine.
Time to dig into bonding.c I guess, if any of the bonding devs could
shed any light on this that would be awesome.

Joseph.

--=20
=46ounder | Director | VP Research
Orion Virtualisation Solutions=A0|=A0www.orionvm.com.au=A0| Phone: 1300=
 56
99 52 | Mobile: 0428 754 846
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
