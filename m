From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_fastretrans_alert since 2.6.32 ?
Date: Wed, 22 Sep 2010 08:48:46 +0200
Message-ID: <1285138126.6378.174.camel@edumazet-laptop>
References: <AANLkTinnaA3Qgny45BRyW3i5u+nXn1XgWwkxA_QbN8xN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Sunny <sunyucong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinnaA3Qgny45BRyW3i5u+nXn1XgWwkxA_QbN8xN@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC netdev and Ilpo

Le mardi 21 septembre 2010 =C3=A0 23:37 -0700, Sunny a =C3=A9crit :
> Hi,
>=20
> After upgrading to the latest ubuntu kernel, I started to have this
> alert showing up, this is a vm running on ESXi host with vmxnet3
> adapter, mainly serving large traffic ~70Mbps towards overboard
> customers, so I expect packet loss and retrans is pretty high. So I'm
> posting to ask whether others been seeing the same issue? When this
> happens, machine freeze several seconds for about three times in a ro=
w
> then seems to start working again.
>=20
> Please cc me on the thread, thanks in advance.
>=20
>=20
> [212670.327617] ------------[ cut here ]------------
> [212670.327689] WARNING: at
> /build/buildd/linux-2.6.32/net/ipv4/tcp_input.c:2919 tcp_fastret
> rans_alert+0x3f9/0xd90()
> [212670.327692] Hardware name: VMware Virtual Platform
> [212670.327693] Modules linked in: btrfs zlib_deflate crc32c libcrc32=
c
> ufs qnx4 hfsplus hfs  minix ntfs vfat msdos fat jfs xfs exportfs
> reiserfs sch_sfq cls_u32 sch_htb nf_conntrack_ipv 6 ip6table_filter
> ip6_tables xt_tcpudp xt_state xt_multiport iptable_filter iptable_nat
> nf_n at nf_conntrack_ipv4 sit nf_conntrack nf_defrag_ipv4 tunnel4
> ip_tables x_tables acpiphp ppde v psmouse parport_pc serio_raw fbcon
> tileblit font bitblit softcursor vmxnet3 vga16fb vgasta te lp parport
> floppy vmw_pvscsi
> [212670.327741] Pid: 0, comm: swapper Not tainted 2.6.32-24-server #4=
2-Ubuntu
> [212670.327742] Call Trace:
> [212670.327744]  <IRQ>  [<ffffffff81066dab>] warn_slowpath_common+0x7=
b/0xc0
> [212670.327754]  [<ffffffff81066e04>] warn_slowpath_null+0x14/0x20
> [212670.327757]  [<ffffffff814b98f9>] tcp_fastretrans_alert+0x3f9/0xd=
90
> [212670.327759]  [<ffffffff814bad24>] tcp_ack+0x284/0x6b0
> [212670.327762]  [<ffffffff814bbab0>] tcp_rcv_established+0x400/0x730
> [212670.327766]  [<ffffffff814c3553>] tcp_v4_do_rcv+0xf3/0x160
> [212670.327769]  [<ffffffff814c4ca5>] tcp_v4_rcv+0x5b5/0x7e0
> [212670.327772]  [<ffffffff814a2c00>] ? ip_local_deliver_finish+0x0/0=
x2d0
> [212670.327776]  [<ffffffff8149a6b4>] ? nf_hook_slow+0x74/0x100
> [212670.327779]  [<ffffffff814a2c00>] ? ip_local_deliver_finish+0x0/0=
x2d0
> [212670.327781]  [<ffffffff814a2cdd>] ip_local_deliver_finish+0xdd/0x=
2d0
> [212670.327783]  [<ffffffff814a2f60>] ip_local_deliver+0x90/0xa0
> [212670.327785]  [<ffffffff814a241d>] ip_rcv_finish+0x12d/0x440
> [212670.327787]  [<ffffffff814a29a5>] ip_rcv+0x275/0x360
> [212670.327794]  [<ffffffff8147319a>] netif_receive_skb+0x38a/0x5d0
> [212670.327801]  [<ffffffffa005203c>]
> vmxnet3_rq_rx_complete+0x23c/0x610 [vmxnet3]
> [212670.327806]  [<ffffffffa005245f>] vmxnet3_do_poll+0x4f/0xf0 [vmxn=
et3]
> [212670.327809]  [<ffffffffa005252d>] vmxnet3_poll+0x2d/0x60 [vmxnet3=
]
> [212670.327816]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0=
x10
> [212670.327820]  [<ffffffff81473c8f>] net_rx_action+0x10f/0x250
> [212670.327824]  [<ffffffff8106e2f7>] __do_softirq+0xb7/0x1e0
> [212670.327828]  [<ffffffff810c4d40>] ? handle_IRQ_event+0x60/0x170
> [212670.327833]  [<ffffffff810142ec>] call_softirq+0x1c/0x30
> [212670.327836]  [<ffffffff81015cb5>] do_softirq+0x65/0xa0
> [212670.327837]  [<ffffffff8106e195>] irq_exit+0x85/0x90
> [212670.327845]  [<ffffffff8155fd45>] do_IRQ+0x75/0xf0
> [212670.327848]  [<ffffffff81013b13>] ret_from_intr+0x0/0x11
> [212670.327849]  <EOI>  [<ffffffff81038acb>] ? native_safe_halt+0xb/0=
x10
> [212670.327855]  [<ffffffff8101b69d>] ? default_idle+0x3d/0x90
> [212670.327860]  [<ffffffff81011e63>] ? cpu_idle+0xb3/0x110
> [212670.327867]  [<ffffffff81552b53>] ? start_secondary+0xa8/0xaa
> [212670.327869] ---[ end trace e26694ca94def524 ]---
>=20
>=20
> Here's netstat -s output
>=20
> Ip:
>     362267935 total packets received
>     0 forwarded
>     0 incoming packets discarded
>     362257901 incoming packets delivered
>     326868094 requests sent out
>     9 fragments dropped after timeout
>     2777 reassemblies required
>     1357 packets reassembled ok
>     9 packet reassembles failed
>     490 fragments received ok
>     1034 fragments created
> Icmp:
>     22430 ICMP messages received
>     283 input ICMP message failed.
>     ICMP input histogram:
>         destination unreachable: 17113
>         timeout in transit: 613
>         redirects: 9
>         echo requests: 4685
>         echo replies: 10
>     7383 ICMP messages sent
>     0 ICMP messages failed
>     ICMP output histogram:
>         destination unreachable: 2695
>         echo request: 11
>         echo replies: 4677
> IcmpMsg:
>         InType0: 10
>         InType3: 17113
>         InType5: 9
>         InType8: 4685
>         InType11: 613
>         OutType0: 4677
>         OutType3: 2695
>         OutType8: 11
> Tcp:
>     6563076 active connections openings
>     1610183 passive connection openings
>     1646225 failed connection attempts
>     75246 connection resets received
>     1141 connections established
>     361192315 segments received
>     323797760 segments send out
>     1997456 segments retransmited
>     12990 bad segments received.
>     1851272 resets sent
> Udp:
>     4138313 packets received
>     186 packets to unknown port received.
>     0 packet receive errors
>     4161268 packets sent
> UdpLite:
> TcpExt:
>     5096 invalid SYN cookies received
>     167 resets received for embryonic SYN_RECV sockets
>     58826 packets pruned from receive queue because of socket buffer =
overrun
>     312 packets pruned from receive queue
>     19 packets dropped from out-of-order queue because of socket buff=
er overrun
>     365 ICMP packets dropped because they were out-of-window
>     2712111 TCP sockets finished time wait in fast timer
>     82068 time wait sockets recycled by time stamp
>     311 packets rejects in established connections because of timesta=
mp
>     11516250 delayed acks sent
>     6415 delayed acks further delayed because of locked socket
>     Quick ack mode was activated 208750 times
>     41789 packets directly queued to recvmsg prequeue.
>     1 bytes directly in process context from backlog
>     2969 bytes directly received in process context from prequeue
>     155660989 packet headers predicted
>     55448128 acknowledgments not containing data payload received
>     89389461 predicted acknowledgments
>     9544 times recovered from packet loss due to fast retransmit
>     585991 times recovered from packet loss by selective acknowledgem=
ents
>     710 bad SACK blocks received
>     Detected reordering 1944 times using FACK
>     Detected reordering 26599 times using SACK
>     Detected reordering 267 times using reno fast retransmit
>     Detected reordering 1819 times using time stamp
>     3169 congestion windows fully recovered without slow start
>     26810 congestion windows partially recovered using Hoe heuristic
>     14402 congestion windows recovered without slow start by DSACK
>     40392 congestion windows recovered without slow start after parti=
al ack
>     115772 TCP data loss events
>     TCPLostRetransmit: 5320
>     1922 timeouts after reno fast retransmit
>     69095 timeouts after SACK recovery
>     11101 timeouts in loss state
>     1151834 fast retransmits
>     74479 forward retransmits
>     225380 retransmits in slow start
>     275631 other TCP timeouts
>     2606 classic Reno fast retransmits failed
>     30507 SACK retransmits failed
>     4862645 packets collapsed in receive queue due to low socket buff=
er
>     260934 DSACKs sent for old packets
>     5109 DSACKs sent for out of order packets
>     95650 DSACKs received
>     819 DSACKs for out of order packets received
>     28142 connections reset due to unexpected data
>     22325 connections reset due to early user close
>     85423 connections aborted due to timeout
>     TCPSACKDiscard: 2319
>     TCPDSACKIgnoredOld: 52587
>     TCPDSACKIgnoredNoUndo: 29859
>     TCPSpuriousRTOs: 2605
>     TCPSackShifted: 3539688
>     TCPSackMerged: 3241543
>     TCPSackShiftFallback: 8938458
> IpExt:
>     InMcastPkts: 2105
>     InBcastPkts: 12
>     InOctets: 1670966745
>     OutOctets: -417434189
>     InMcastOctets: 58940
>     InBcastOctets: 1792
