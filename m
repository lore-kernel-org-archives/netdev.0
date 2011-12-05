From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: WARNING: at net/core/dev.c:1904
	skb_gso_segment+0x146/0x298()
Date: Mon, 5 Dec 2011 15:02:54 -0800
Message-ID: <20111205150254.00004b9b@unknown>
References: <4ECD902A.8080206@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4ECD902A.8080206@itcare.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

cc: e1000-devel

On Wed, 23 Nov 2011 16:30:34 -0800
Pawe=B3 Staszewski <pstaszewski@itcare.pl> wrote:
> After upgrade from 2.6.38.2 to 3.1.2 i have this im dmesg:
> [  600.266497] WARNING: at net/core/dev.c:1904 skb_gso_segment+0x146/0x29=
8()
> [  600.266500] Hardware name: X8DTU-6+
> [  600.266503] 802.1Q VLAN Support: caps=3D(0x20115833, 0x0) len=3D2816 =

> data_len=3D2776 ip_summed=3D1

it seems no-one ever replied, can you give us more details about the
traffic and network configuration that reproduces the panic?

what does the output of 'ip address' show? vconfig?

it seems as if GRO is pushing a packet into the stack to be forwarded
that gso is mad about due to checksum !=3D CHECKSUM_PARTIAL, esp when
stacked upon macvlan and/or vlan:

see dev.c:1904 in 3.1 kernel


> [  600.266506] Modules linked in: macvlan
> [  600.266511] Pid: 0, comm: kworker/0:1 Not tainted 3.1.2 #1
> [  600.266513] Call Trace:
> [  600.266515] <IRQ>  [<ffffffff8103449c>] warn_slowpath_common+0x80/0x98
> [  600.266527]  [<ffffffff81034548>] warn_slowpath_fmt+0x41/0x43
> [  600.266530]  [<ffffffff813c838f>] skb_gso_segment+0x146/0x298
> [  600.266535]  [<ffffffff8103994e>] ? local_bh_enable+0xd/0xf
> [  600.266540]  [<ffffffff813cc646>] dev_hard_start_xmit+0x35a/0x57d
> [  600.266544]  [<ffffffff8103994e>] ? local_bh_enable+0xd/0xf
> [  600.266548]  [<ffffffff813cccb2>] dev_queue_xmit+0x449/0x4ef
> [  600.266554]  [<ffffffff813ffc4d>] ip_finish_output2+0x1c4/0x201
> [  600.266560]  [<ffffffff813ffd1c>] ip_finish_output+0x92/0x97
> [  600.266562]  [<ffffffff813ffe7c>] T.1037+0x4f/0x56
> [  600.266565]  [<ffffffff81400005>] ip_output+0x58/0x5b
> [  600.266567]  [<ffffffff813fc4f0>] ip_forward_finish+0x44/0x48
> [  600.266569]  [<ffffffff813fc7f4>] ip_forward+0x300/0x36c
> [  600.266572]  [<ffffffff813fb144>] ip_rcv_finish+0x2a4/0x2ce
> [  600.266575]  [<ffffffff813faea0>] ? inet_del_protocol+0x37/0x37
> [  600.266577]  [<ffffffff813fb431>] T.935+0x4c/0x53
> [  600.266579]  [<ffffffff813fb6bc>] ip_rcv+0x237/0x263
> [  600.266582]  [<ffffffff813cb76b>] __netif_receive_skb+0x41d/0x44f
> [  600.266584]  [<ffffffff813cb891>] process_backlog+0xf4/0x1d3
> [  600.266587]  [<ffffffff813cbfee>] net_rx_action+0x74/0x1cb
> [  600.266589]  [<ffffffff81039a74>] __do_softirq+0xc8/0x1a4
> [  600.266591]  [<ffffffff81039b31>] ? __do_softirq+0x185/0x1a4
> [  600.266595]  [<ffffffff814a8bec>] call_softirq+0x1c/0x30
> [  600.266599]  [<ffffffff8100385d>] do_softirq+0x41/0x7e
> [  600.266601]  [<ffffffff8103987b>] irq_exit+0x44/0x74
> [  600.266603]  [<ffffffff81003182>] do_IRQ+0x98/0xaf
> [  600.266606]  [<ffffffff814a0f2e>] common_interrupt+0x6e/0x6e
> [  600.266608] <EOI>  [<ffffffff8100887e>] ? mwait_idle+0x7e/0xa4
> [  600.266613]  [<ffffffff81008836>] ? mwait_idle+0x36/0xa4
> [  600.266615]  [<ffffffff81001da7>] cpu_idle+0x5f/0x91
> [  600.266620]  [<ffffffff81acca55>] start_secondary+0x192/0x196
> [  600.266622] ---[ end trace 15512840060b2da9 ]---
> =

> Network controller: Intel Corporation 82598EB 10-Gigabit AT CX4 Network =

> Connection (rev 01)
> ethtool -i eth4
> driver: ixgbe
> version: 3.4.8-k
> firmware-version: 1.12-2
> bus-info: 0000:04:00.0
> =

> ethtool -k eth4
> Offload parameters for eth4:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: on


---------------------------------------------------------------------------=
---
All the data continuously generated in your IT infrastructure =

contains a definitive record of customers, application performance, =

security threats, fraudulent activity, and more. Splunk takes this =

data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
