From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [BUG] Lockup on boot when trying to bring up r8169 NIC
Date: Mon, 23 Jul 2007 15:37:42 -0400
Message-ID: <20070723193740.GA31284@gospo.rdu.redhat.com>
References: <469F7117.2020404@mathtm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas =?iso-8859-1?Q?M=FCller?= <thomas@mathtm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763191AbXGWThp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 15:37:45 -0400
Content-Disposition: inline
In-Reply-To: <469F7117.2020404@mathtm.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:11:35PM +0200, Thomas M=FCller wrote:
> Hi,
>=20
> I already sent this two days ago, but I have the feeling it was
> overlooked or filtered because of a large attachment.
>=20
>=20
> If I try to boot 2.6.21.6, 2.6.22.1 or 2.6.22-git8 the system complet=
ely
> hangs when init tries to bring up my r8169-based NIC. Not even the
> keyboard lights are working anymore.
>=20
> If I unplug the network cable, boot continues just fine and everythin=
g
> works as it should.
> If I boot with the cable unplugged, the system also hangs and continu=
es
> after I plug in the cable.
>=20
>=20
> Everything works fine with 2.6.20.15.
>=20
>=20
> Configuration:
>   http://www.mathtm.de/config_2.6.20.15_fc6based
>   http://www.mathtm.de/config_2.6.21.6_f7based
>=20
>=20
> Using a Fedora kernel (based on 2.6.21.5) I get the following kernel
> message:
> r8169: eth0: link down
> BUG: soft lockup detected on CPU#0!
>  [<c0451ea2>] softlockup_tick+0xa5/0xb4
>  [<c042e930>] update_process_times+0x3b/0x5e
>  [<c043d298>] tick_sched_timer+0x57/0x9a
>  [<c0439df5>] hrtimer_interrupt+0x12b/0x1b6
>  [<c043d241>] tick_sched_timer+0x0/0x9a
>  [<c0408534>] timer_interrupt+0x2c/0x32
>  [<c045210e>] handle_IRQ_event+0x1a/0x3f
>  [<c045354e>] handle_level_irq+0x81/0xc7
>  [<c04072c7>] do_IRQ+0xb8/0xd1
>  [<c04058ff>] common_interrupt+0x23/0x28
>  [<c0452105>] handle_IRQ_event+0x11/0x3f
>  [<c045354e>] handle_level_irq+0x81/0xc7
>  [<c04534cd>] handle_level_irq+0x0/0xc7
>  [<c04072bb>] do_IRQ+0xac/0xd1
>  [<c04058ff>] common_interrupt+0x23/0x28
>  [<c042b2dc>] __do_softirq+0x54/0xba
>  [<c04071b7>] do_softirq+0x59/0xb1
>  [<c04534cd>] handle_level_irq+0x0/0xc7
>  [<c042b194>] irq_exit+0x38/0x6b
>  [<c04072cc>] do_IRQ+0xbd/0xd1
>  [<c04058ff>] common_interrupt+0x23/0x28
>  [<c04200d8>] find_busiest_group+0x264/0x4c5
>  [<c0601895>] _spin_unlock_irqrestore+0x8/0x9
>  [<c042e863>] __mod_timer+0xa1/0xab
>  [<f8a4e1ec>] rtl8169_open+0x12e/0x194 [r8169]
>  [<c05a3054>] dev_open+0x2b/0x62
>  [<c05a1aa1>] dev_change_flags+0x47/0xe4
>  [<c05de45c>] devinet_ioctl+0x250/0x56a
>  [<c04e72c0>] copy_to_user+0x3c/0x50
>  [<c0598b47>] sock_ioctl+0x19f/0x1be
>  [<c05989a8>] sock_ioctl+0x0/0x1be
>  [<c047f713>] do_ioctl+0x1f/0x62
>  [<c047f99a>] vfs_ioctl+0x244/0x256
>  [<c047f9f8>] sys_ioctl+0x4c/0x64
>  [<c0404f70>] syscall_call+0x7/0xb
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> r8169: eth0: link up
>=20
>=20
>=20
> There already is a bugzilla entry at
> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D242572
> I know, not everyone is a fan of bugzilla, but maybe someone wants to
> take a look at what was discussed there.
>=20
>=20
> Please CC me as I'm not subscribed to the list and don't hesitate to
> tell me that I forgot to include some crucial information ;)
>=20
>=20
> Regards,
> Thomas
>=20


As you know already this seems to be caused by an undesireable
interaction between the r8169 driver and a kernel with
CONFIG_DEBUG_SHIRQ=3Dy. =20

It seems rtl8169_interrupt will spin (or hang) while booting until ther=
e
is an interrupt to service (like a link-change event).

-andy

