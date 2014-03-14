From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: Zynq macb
Date: Fri, 14 Mar 2014 08:46:49 -0700
Message-ID: <d1a10044-b85c-4664-8fc3-2fb3c7e1a274@CO9EHSMHS026.ehs.local>
References: <c6344e9b-fa32-4313-8950-59030c4bffb8@AM1EHSMHS003.ehs.local>
 <73734ba5-00d3-445d-8c6f-a1a868cdd537@CH1EHSMHS024.ehs.local>
 <53229584.7000100@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Michal Simek <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53229584.7000100@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-14 at 06:37AM +0100, Michal Simek wrote:
> On 03/13/2014 11:33 PM, S=C3=B6ren Brinkmann wrote:
> > On Thu, 2014-03-13 at 03:16PM -0700, S=C3=B6ren Brinkmann wrote:
> >> Hi Nicolas,
> >>
> >> I did some testing on the current linux-next tree and ran iperf on=
 Zynq.
> >> It seems that network and even the whole system can collapse when =
doing
> >> that.
> >> I don't really know what's going on, but once I saw the message:
> >> 	"inconsistent Rx descriptor chain"
> >> printed twice (system frozen afterwards).
> >>
> >> I don't know what exactly is going wrong, but suspect something ar=
ound
> >> memory/DMA. I have no clue whether it makes any sense or not, but =
I
> >> tried using the macb_* functions instead of the gem_* ones (see di=
ff below).
> >> That seems to result in a stable system and working Ethernet.
> >=20
> > That was a little too early. After roughly 25 minutest the system r=
uns
> > into a deadlock:
> >   BUG: spinlock lockup suspected on CPU#1, iperf/774
> >    lock: 0xeda0366c, .magic: dead4ead, .owner: swapper/0/0, .owner_=
cpu: 0
> >   CPU: 1 PID: 774 Comm: iperf Tainted: G        W    3.14.0-rc6-nex=
t-20140312-xilinx-dirty #41
> >   [<c00153c0>] (unwind_backtrace) from [<c0011e70>] (show_stack+0x1=
0/0x14)
> >   [<c0011e70>] (show_stack) from [<c03d6b50>] (dump_stack+0x80/0xcc=
)
> >   [<c03d6b50>] (dump_stack) from [<c00670ac>] (do_raw_spin_lock+0xd=
4/0x190)
> >   [<c00670ac>] (do_raw_spin_lock) from [<c03dc79c>] (_raw_spin_lock=
_irqsave+0x58/0x64)
> >   [<c03dc79c>] (_raw_spin_lock_irqsave) from [<c02b0810>] (macb_sta=
rt_xmit+0x24/0x2d0)
> >   [<c02b0810>] (macb_start_xmit) from [<c0321b10>] (dev_hard_start_=
xmit+0x334/0x470)
> >   [<c0321b10>] (dev_hard_start_xmit) from [<c0339aa8>] (sch_direct_=
xmit+0x78/0x2f8)
> >   [<c0339aa8>] (sch_direct_xmit) from [<c0321f60>] (__dev_queue_xmi=
t+0x314/0x704)
> >   [<c0321f60>] (__dev_queue_xmit) from [<c034cb3c>] (ip_finish_outp=
ut+0x6c4/0x894)
> >   [<c034cb3c>] (ip_finish_output) from [<c034cf24>] (ip_local_out+0=
x74/0x90)
> >   [<c034cf24>] (ip_local_out) from [<c034d340>] (ip_queue_xmit+0x40=
0/0x5c4)
> >   [<c034d340>] (ip_queue_xmit) from [<c03634b8>] (tcp_transmit_skb+=
0xa18/0xab0)
> >   [<c03634b8>] (tcp_transmit_skb) from [<c035856c>] (tcp_recvmsg+0x=
92c/0xae4)
> >   [<c035856c>] (tcp_recvmsg) from [<c03806f0>] (inet_recvmsg+0x1c0/=
0x1fc)
> >   [<c03806f0>] (inet_recvmsg) from [<c030769c>] (sock_recvmsg+0x7c/=
0x98)
> >   [<c030769c>] (sock_recvmsg) from [<c0309988>] (SyS_recvfrom+0x9c/=
0x108)
> >   [<c0309988>] (SyS_recvfrom) from [<c0309a08>] (sys_recv+0x14/0x18=
)
> >   [<c0309a08>] (sys_recv) from [<c000ea60>] (ret_fast_syscall+0x0/0=
x48)
>=20
> Do you have this change in your tree?
> https://github.com/Xilinx/linux-xlnx/commit/1a85939af40acca2bf963407b=
497cc31c303ff3e
>=20
> I don't think we have sent this to mainline yet.

If it's not in next, it wasn't in my kernel.

	S=C3=B6ren
