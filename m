From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Fri, 25 Jan 2008 09:30:42 +0800
Message-ID: <a8e1da0801241730h4e0a696cmbd9f26ed57f3c3e2@mail.gmail.com>
References: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
	 <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801221744m37021e88h5c188e5b31ea42bf@mail.gmail.com>
	 <20080122.190137.206066966.davem@davemloft.net>
	 <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
	 <Pine.LNX.4.64.0801231034300.31652@kivilampi-30.cs.helsinki.fi>
	 <Pine.LNX.4.64.0801231256360.31652@kivilampi-30.cs.helsinki.fi>
	 <a8e1da0801231842m128d8261oc14135716a0a2d85@mail.gmail.com>
	 <Pine.LNX.4.64.0801241108400.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kamalesh Babulal" <kamalesh@linux.vnet.ibm.com>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Denys Fedoryshchenko" <denys@visp.net.lb>,
	"David Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.233]:56524 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbYAYBaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:30:46 -0500
Received: by nz-out-0506.google.com with SMTP id s18so368985nze.1
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2008 17:30:43 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0801241108400.31652@kivilampi-30.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 24, 2008 5:54 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wr=
ote:
> On Thu, 24 Jan 2008, Dave Young wrote:
>
> Hi Dave (& others),
>
> > Thanks.
>
> Thanks a lot, I was first to ignore all these because they occurred
> with newreno, but looked again... :-/
>
> > New warning trigged with your debug patch:
>
> This was probably with the earlier one I sent to you because there's =
still
> this case remaining which itself is valid:
>
> > P: 5 L: 0 vs 0 S: 0 vs 1 w: 2044790889-2044796616 (0)
>
> ...snip... this is still ok state (S+L <=3D P):
>
>
> > P: 5 L: 0 vs 0 S: 0 vs 3 w: 2044790889-2044796616 (0)
> > TCP wq(s)      <
> > TCP wq(h) +++h+<
> > l0 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x122/0x15=
0()
> > Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
> > snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmous=
e
> > snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x=
 sg
> > evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
> > i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
> > Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
> >  [<c0132100>] ? have_callable_console+0x20/0x30
> >  [<c0131844>] warn_on_slowpath+0x54/0x80
> >  [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
> >  [<c0132438>] ? vprintk+0x308/0x320
> >  [<c0132438>] ? vprintk+0x308/0x320
> >  [<c0132438>] ? vprintk+0x308/0x320
> >  [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
> >  [<c03f6052>] tcp_mark_head_lost+0x122/0x150
> >  [<c03f60ca>] tcp_update_scoreboard+0x4a/0x190
> >  [<c03f6e7a>] tcp_fastretrans_alert+0x4da/0x700
> >  [<c03f7e63>] tcp_ack+0x1b3/0x3a0
> >  [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
> >  [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
> >  [<c04021fb>] tcp_v4_rcv+0x5db/0x660
> >  [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
> >  [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
> >  [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
> >  [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
> >  [<c0156b97>] ? __lock_release+0x47/0x70
> >  [<c03e6147>] ip_local_deliver+0xb7/0xc0
> >  [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
> >  [<c03c01d8>] ? sock_def_readable+0x48/0xa0
> >  [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
> >  [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
> >  [<c03e669f>] ip_rcv+0x18f/0x290
> >  [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
> >  [<c03c8da6>] netif_receive_skb+0x2b6/0x330
> >  [<c03c8c17>] ? netif_receive_skb+0x127/0x330
> >  [<c03c8ea3>] ? process_backlog+0x83/0x100
> >  [<c03c8eae>] process_backlog+0x8e/0x100
> >  [<c03c90bc>] net_rx_action+0x13c/0x230
> >  [<c03c8fd9>] ? net_rx_action+0x59/0x230
> >  [<c0136f63>] __do_softirq+0x93/0x120
> >  [<c013706a>] do_softirq+0x7a/0x80
> >  [<c0137135>] irq_exit+0x65/0x90
> >  [<c01078b1>] do_IRQ+0x41/0x80
> >  [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
> >  [<c01059ca>] common_interrupt+0x2e/0x34
> >  [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
> >  [<c01033a0>] ? mwait_idle+0x0/0x20
> >  [<c01033b2>] mwait_idle+0x12/0x20
> >  [<c0103141>] cpu_idle+0x61/0x110
> >  [<c04339fd>] rest_init+0x5d/0x60
> >  [<c05a47fa>] start_kernel+0x1fa/0x260
> >  [<c05a4190>] ? unknown_bootoption+0x0/0x130
> >  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> > ---[ end trace 14b601818e6903ac ]---
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_ipv4.c:197 tcp_verify_wq+0x1b6/0x1c0()
> > Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event
> > snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmous=
e
> > snd_hda_intel snd_pcm snd_timer btusb bluetooth serio_raw snd 3c59x=
 sg
> > evdev thermal soundcore rtc_cmos snd_page_alloc rtc_core rtc_lib
> > i2c_i801 processor button intel_agp dcdbas pcspkr agpgart
> > Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #8
> >  [<c0132100>] ? have_callable_console+0x20/0x30
> >  [<c0131844>] warn_on_slowpath+0x54/0x80
> >  [<c01317da>] ? print_oops_end_marker+0x2a/0x30
> >  [<c0131849>] ? warn_on_slowpath+0x59/0x80
> >  [<c03ffe54>] ? tcp_print_queue+0x1a4/0x230
> >  [<c0132438>] ? vprintk+0x308/0x320
> >  [<c0132438>] ? vprintk+0x308/0x320
> >  [<c0400096>] tcp_verify_wq+0x1b6/0x1c0
> >  [<c03ffff6>] ? tcp_verify_wq+0x116/0x1c0
> >  [<c03f5ffc>] tcp_mark_head_lost+0xcc/0x150
> >  [<c03f60ca>] tcp_update_scoreboard+0x4a/0x190
> >  [<c03f6e7a>] tcp_fastretrans_alert+0x4da/0x700
> >  [<c03f7e63>] tcp_ack+0x1b3/0x3a0
> >  [<c03fa21b>] tcp_rcv_established+0x3eb/0x710
> >  [<c0401c05>] tcp_v4_do_rcv+0xe5/0x100
> >  [<c04021fb>] tcp_v4_rcv+0x5db/0x660
> >  [<c0401fa7>] ? tcp_v4_rcv+0x387/0x660
> >  [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
> >  [<c03e5f44>] ip_local_deliver_finish+0x84/0x1d0
> >  [<c03e5eed>] ? ip_local_deliver_finish+0x2d/0x1d0
> >  [<c0156b97>] ? __lock_release+0x47/0x70
> >  [<c03e6147>] ip_local_deliver+0xb7/0xc0
> >  [<c03e6202>] ip_rcv_finish+0xb2/0x3c0
> >  [<c03c01d8>] ? sock_def_readable+0x48/0xa0
> >  [<c03be061>] ? sock_queue_rcv_skb+0xb1/0x1a0
> >  [<c03be0a7>] ? sock_queue_rcv_skb+0xf7/0x1a0
> >  [<c03e669f>] ip_rcv+0x18f/0x290
> >  [<c042fb10>] ? packet_rcv_spkt+0xd0/0x130
> >  [<c03c8da6>] netif_receive_skb+0x2b6/0x330
> >  [<c03c8c17>] ? netif_receive_skb+0x127/0x330
> >  [<c03c8ea3>] ? process_backlog+0x83/0x100
> >  [<c03c8eae>] process_backlog+0x8e/0x100
> >  [<c03c90bc>] net_rx_action+0x13c/0x230
> >  [<c03c8fd9>] ? net_rx_action+0x59/0x230
> >  [<c0136f63>] __do_softirq+0x93/0x120
> >  [<c013706a>] do_softirq+0x7a/0x80
> >  [<c0137135>] irq_exit+0x65/0x90
> >  [<c01078b1>] do_IRQ+0x41/0x80
> >  [<c0155659>] ? trace_hardirqs_on+0xb9/0x130
> >  [<c01059ca>] common_interrupt+0x2e/0x34
> >  [<c0103390>] ? mwait_idle_with_hints+0x40/0x50
> >  [<c01033a0>] ? mwait_idle+0x0/0x20
> >  [<c01033b2>] mwait_idle+0x12/0x20
> >  [<c0103141>] cpu_idle+0x61/0x110
> >  [<c04339fd>] rest_init+0x5d/0x60
> >  [<c05a47fa>] start_kernel+0x1fa/0x260
> >  [<c05a4190>] ? unknown_bootoption+0x0/0x130
> >  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> > ---[ end trace 14b601818e6903ac ]---
>
> ...But this no longer is, and even more, L: 5 is not valid state at t=
his
> point all (should only happen if we went to RTO but it would reset S =
to
> zero with newreno):
>
> > P: 5 L: 5 vs 5 S: 0 vs 3 w: 2044790889-2044796616 (0)
> > TCP wq(s) LLLLl<
> > TCP wq(h) +++h+<
> > l5 s3 f0 p5 seq: su2044790889 hs2044795029 sn2044796616
>
> Surprisingly, it was the first time the WARN_ON for left_out returned
> correct location. This also explains why the patch I sent to Krishna
> didn't print anything (it didn't end up into printing because I forgo=
t
> to add L+S>P check into to the state checking if).
>
> ...so please, could you (others than Denys) try this patch, it should
> solve the issue. And Denys, could you confirm (and if necessary doubl=
e
> check) that the kernel you saw this similar problem with is the pure
> Linus' mainline, i.e., without any net-2.6.25 or mm bits please, if s=
o,
> that problem persists. And anyway, there were some fackets_out relate=
d
> problems reported as well and this doesn't help for that but I think =
I've
> lost track of who was seeing it due to large number of reports :-), c=
ould
> somebody refresh my memory because I currently don't have time to dig=
 it
> up from archives (at least on this week).

Thanks, applied on my test kernel, if there's no warnings I will just m=
ute.

>
>
> --
>  i.
>
> --
> [PATCH] [TCP]: NewReno must count every skb while marking losses
>
> NewReno should add cnt per skb (as with FACK) instead of depending
> on SACKED_ACKED bits which won't be set with it at all.
> Effectively, NewReno should always exists after the first
> iteration anyway (or immediately if there's already head in
> lost_out.
>
> This was fixed earlier in net-2.6.25 but got reverted among other
> stuff and I didn't notice that this is still necessary (actually
> wasn't even considering this case while trying to figure out the
> reports because I lived with different kind of code than it in
> reality was).
>
> This should solve the WARN_ONs in TCP code that as a result of
> this triggered multiple times in every place we check for this
> invariant.
>
> Special thanks to Dave Young <hidave.darkstar@gmail.com> and
> Krishna Kumar2 <krkumar2@in.ibm.com> for trying with my debug
> patches.
>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 295490e..aa409a5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2156,7 +2156,7 @@ static void tcp_mark_head_lost(struct sock *sk,=
 int packets, int fast_rexmit)
>                 tp->lost_skb_hint =3D skb;
>                 tp->lost_cnt_hint =3D cnt;
>
> -               if (tcp_is_fack(tp) ||
> +               if (tcp_is_fack(tp) || tcp_is_reno(tp) ||
>                     (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
>                         cnt +=3D tcp_skb_pcount(skb);
>
> --
> 1.5.2.2
>
