From: =?iso-8859-1?Q?=C9ric?= Brunet <Eric.Brunet@lps.ens.fr>
Subject: Re: test9, complete lockup, ipchains related
Date: Tue, 28 Oct 2003 13:40:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028124031.GA19567@lps.ens.fr>
References: <20031027205235.GA18206@lps.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davidm@napali.hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter@lists.netfilter.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031027205235.GA18206@lps.ens.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

This is a repost of a message I sent yesterday to linux-kernel. I
understand I should have sent it there right away. Please note, that
another instance of (probably) the same problem on an ia64 platform has
also been reported by David Mosberger on linux-kernel, and he has a
better trace than I do. Please see
<http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D106730476106084&w=3D2=
>=20
and  <http://tinyurl.com/sm9d> for his report.

Please, Cc me any answer.

Thanks,

	=C9ric Brunet

On Mon, Oct 27, 2003 at 09:52:35PM +0100, =C9ric Brunet wrote:
> I have the following setup on my PIV computer, shuttle motherboard,
> 2.6.0-test9 kernel:
>=20
> eth1 is a RTL-8029 and connects me to the outside world
> eth0 is a RT8139 and is where I plug my laptop.
>=20
> Using ipchains, I masqerade the laptop, so that it can also access the
> outside world.
>=20
> The problem is that my computer locks up when I try to do a big backup
> with rsync over ssh from the laptop to a computer in the outside world.
> No mouse, no keyboard, nothing in the logs.
>=20
> I couldn't reproduce it with some scp from the laptop to a computer ove=
r
> the outside world. I don't know what is so special with rsync.
>=20
> I couldn't reproduce it with a rsync from the laptop to my computer. Th=
at
> is why I think it is ipchains related.
>=20
> Everything is working fine with kernels -test1 and -test4. The lockup i=
s
> already present in -test8 and, I think, -test7 (need to check that).
>=20
> Once I constated the problem with a complete boot (X11, kde, many
> services), I have reproduced them in booting in single user mode, with =
no
> more operations than ifup'ing eth0, eth1, loading ipchains and setting
> the one single rule (masqerading) I need.
>=20
> ONCE, I got some kernel trace spit out on the console before the comput=
er
> locked. Unfortunately, I only got the 24 last lines. I tried to obtain
> another trace in a 80x60 vga mode, but failed. Here is the trace, hand
> copied:
>=20
> 	ip_rcv_finish +0x1c5/0x22c
> 	ip_rcv_finish +0x0/0x22c
> 	nf_hook_slow +0xd4/0x122
> 	ip_rcv_finish +0x0/0x22c
> 	ip_rcv +0x3c5/0x480
> 	ip_rcv_finish +0x0/0x22c
> 	netif_receive_skb +0x12b/0x164
> 	process_backlog +0x6e/0xfd
> 	net_rx_action +0x6a/0xe4
> 	do_softirq +0x95/0x97
> 	do_IRQ +0xca/0xe5
> 	default_idle +0x0/0x27
> 	rest_init +0x0/0x27
> 	common_interrupt +0x18/0x20
> 	default_idle +0x0/0x27
> 	rest_init +0x0/0x27
> 	default_idle +0x24/0x27
> 	cpu_idle +0x2e/0x37
> 	start_kernel +0x163/0x191
> 	unknown_bootoption +0x0/0xff
> Code 8b 53 08 0f b7 47 0e 31 f6 66 39 42 1e 74 1f 85 f6 75 07 a1
> 	Kernel panic: Fatal exception in interrupt
> 	In interrupt handler - not syncing
>=20
> .config, dmesg, lspci, etc. available on
> http://perso.nerim.net/~tudia/bug-reports
>=20
>=20
> Regards,
>=20
> 	=C9ric Brunet
