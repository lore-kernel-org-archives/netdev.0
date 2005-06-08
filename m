From: Jon Mason <jdmason@gmail.com>
Subject: dl2k tx timeout problems
Date: Wed, 8 Jun 2005 09:10:16 -0500
Message-ID: <8924577505060807103eac03b2@mail.gmail.com>
References: <883AD1ABBCC79842ACCEDB1BE3E5B78C03B2B5F6@srvexch01siege.Outremer.rfo.fr>
Reply-To: Jon Mason <jdmason@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: MOUNIER Emmanuel <Emmanuel.MOUNIER@rfo.fr>
In-Reply-To: <883AD1ABBCC79842ACCEDB1BE3E5B78C03B2B5F6@srvexch01siege.Outremer.rfo.fr>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bonjour,
Please see my comments below.

On 6/8/05, MOUNIER Emmanuel <Emmanuel.MOUNIER@rfo.fr> wrote:
> Hello!
>             I'm not sure, but I think the EMT 64 is for the extended PC=
I Slot (64bits), right?

Actually no, EMT64 is Intel's version of 64bit extensions (similar to
AMD's athlon64/opteron).  This enables you to run a 64bit kernel or a
32bit kernel.  If you installed a standard x86 version of Linux, then
you are running in 32bit mode.  if you installed something for x86_64
(sometimes called amd64), then you are running in 64bit mode.  "uname
-a" will show you which one you are running.

> If  it's true, yes, my card work in 64bits mode, and I think it's maybe=
 the problem, because the DGE-550SX card work perfectly on some of our ol=
d server in standard PCI slot (32bits).

I think this is worth noting.  I'll investigate this with my copper adapt=
er.=20

>             I've tried many kernel versions without success, but actual=
ly I'm running kernel 2.6.8.1-10smp on a Mandrake Linux 10.1.

What other kernels have you tried?  Have you tried a vanilla kernel
from kernel.org?
=20
>             Now, I will try to explain my problem as clear as I can:
>=20
>             I've plugged the card, and turned on my Linux box. The card=
 was detected perfectly and the module was loaded at the boot.
>=20
>             I can assign an IP address to the card, and I'm able to pin=
g my network. After a short time, the network traffic completely hangs an=
d it says: TX timeout, is buffer full?
=20
how long (an estimate is fine) before the system experiences the tx
timeout?  What kind of network traffic is the systeming doing during
this time?  Are the systems idle?  are they running NFS?
=20
=20
>             When I restart the network service, I can see in my logs th=
at Linux simply disable the IRQ of my NIC:
=20
Can you send me the output of "lspci -v"?  This will help confirm that
no other devices shares the same interrupt.
=20
> /var/log/messages :
>=20
>=20
>=20
> FWRFO kernel: eth2: D-Link DGE-550SX Gigabit Ethernet Adapter, 00:0d:88=
:b5:f3:f5, IRQ 4
>=20
> FWRFO kernel: tx_coalesce:^I16 packets
>=20
> FWRFO kernel: rx_coalesce:^I10 packets
>=20
> FWRFO kernel: rx_timeout: ^I128000 ns
>=20
> FWRFO kernel: Uhhuh. NMI received. Dazed and confused, but trying to co=
ntinue
>=20
> FWRFO kernel: You probably have a hardware problem with your RAM chips


The error above is a memory parity error.  That is definately not
good.  Are you seeing this error very often?

> FWRFO kernel: eth2: Link off
>=20
> FWRFO kernel: eth2: Link up
>=20
> FWRFO kernel: Auto 1000 Mbps, Full duplex
>=20
> FWRFO kernel: Enable Tx Flow Control
>=20
> FWRFO kernel: Enable Rx Flow Control
>=20
> FWRFO kernel: irq 4: nobody cared!
>=20
> FWRFO kernel:  [dump_stack+30/32] dump_stack+0x1e/0x20
>=20
> FWRFO kernel:  [<c0107e3e>] dump_stack+0x1e/0x20
>=20
> FWRFO kernel:  [__report_bad_irq+43/144] __report_bad_irq+0x2b/0x90
>=20
> FWRFO kernel:  [<c010945b>] __report_bad_irq+0x2b/0x90
>=20
> FWRFO kernel:  [note_interrupt+144/176] note_interrupt+0x90/0xb0
>=20
> FWRFO kernel:  [<c0109570>] note_interrupt+0x90/0xb0
>=20
> FWRFO kernel:  [do_IRQ+272/304] do_IRQ+0x110/0x130
>=20
> FWRFO kernel:  [<c0109850>] do_IRQ+0x110/0x130
>=20
> FWRFO kernel:  [common_interrupt+24/32] common_interrupt+0x18/0x20
>=20
> FWRFO kernel:  [<c0107960>] common_interrupt+0x18/0x20
>=20
> FWRFO kernel:  [do_softirq+53/64] do_softirq+0x35/0x40
>=20
> FWRFO kernel:  [<c01278f5>] do_softirq+0x35/0x40
>=20
> FWRFO kernel:  [do_IRQ+279/304] do_IRQ+0x117/0x130
>=20
> FWRFO kernel:  [<c0109857>] do_IRQ+0x117/0x130
>=20
> FWRFO kernel:  [common_interrupt+24/32] common_interrupt+0x18/0x20
>=20
> FWRFO kernel:  [<c0107960>] common_interrupt+0x18/0x20
>=20
> FWRFO kernel:  [pg0+945814381/1069203456] rio_open+0x5d/0x210 [dl2k]
>=20
> FWRFO kernel:  [<f8a51b6d>] rio_open+0x5d/0x210 [dl2k]
>=20
> FWRFO kernel:  [dev_open+232/256] dev_open+0xe8/0x100
>=20
> FWRFO kernel:  [<c0287bf8>] dev_open+0xe8/0x100
>=20
> FWRFO kernel:  [dev_change_flags+88/304] dev_change_flags+0x58/0x130
>=20
> FWRFO kernel:  [<c0289378>] dev_change_flags+0x58/0x130
>=20
> FWRFO kernel:  [devinet_ioctl+1392/1584] devinet_ioctl+0x570/0x630
>=20
> FWRFO kernel:  [<c02cda60>] devinet_ioctl+0x570/0x630
>=20
> FWRFO kernel:  [inet_ioctl+192/208] inet_ioctl+0xc0/0xd0
>=20
> FWRFO kernel:  [<c02cfd60>] inet_ioctl+0xc0/0xd0
>=20
> FWRFO kernel:  [sock_ioctl+522/720] sock_ioctl+0x20a/0x2d0
>=20
> FWRFO kernel:  [<c027ecca>] sock_ioctl+0x20a/0x2d0
>=20
> FWRFO kernel:  [sys_ioctl+586/662] sys_ioctl+0x24a/0x296
>=20
> FWRFO kernel:  [<c0174ffa>] sys_ioctl+0x24a/0x296
>=20
> FWRFO kernel:  [sysenter_past_esp+82/113] sysenter_past_esp+0x52/0x71
>=20
> FWRFO kernel:  [<c0106fa1>] sysenter_past_esp+0x52/0x71
>=20
> FWRFO kernel: handlers:
>=20
> FWRFO kernel: [pg0+945816320/1069203456] (rio_interrupt+0x0/0xf0 [dl2k]=
)
>=20
> FWRFO kernel: [<f8a52300>] (rio_interrupt+0x0/0xf0 [dl2k])
>=20
> FWRFO kernel: Disabling IRQ #4
=20

The bad interrupt is most likely related to the restarting of the
network while the adapter is hung.


>             I went to the BIOS setup, and I set the system to not share=
 the IRQ for my NIC.
>=20
>=20
>=20
>             I've tried with several DLINK NIC of the same series, and i=
n 4 DL-360 HP servers, so I don't think it's a hardware malfunction.
>=20
>=20
>=20
>             I also tried to build a new kernel without power management=
, and with the Dlink drivers include in the kernel (not in a module).
>=20
>=20
>=20
>             I can try as many debug patch as you want =3D)

Great!  I'm sure I'll have something for you to test.  I can send you
the patch that I sent to Richard.  It solves the problem under light
load, but the network will still hang under high load.

>=20
>=20
>             And sure, you can forward our mails to the Linux kernel net=
work mailing list.

I have CC'ed them on this e-mail, and changed the subject accordingly.=20
=20
=20
>             I have some knowledge in Linux OS, but I'm very poor in sof=
tware development, so maybe you must explain me in details what I must do=
 for patching, etc...
>=20

I'll be happy to explain when the time comes.

> Thanks you very much, and sorry for my poor English...

Your English is very good (and loads better than my French). =20

> Emmanuel Mounier
>=20
> Charg=E9 de projet direction Technique
>=20
> RFO ( www.rfo.fr )
>=20
> mail : emmanuel.mounier@rfo.fr
>=20
>=20
> ________________________________
>=20
> De: Jon Mason [mailto:jdmason@gmail.com]
> Date: mar. 07/06/2005 18:35
> =C0: MOUNIER Emmanuel
> Objet : Re: Help : Big Problem With DLINK Fiber NIC
>=20
>=20
>=20
> Bonjour!
>=20
> I am happy to help.  My previous experience has been with the copper
> adapters (I have one at home), but the fiber ones should be fairly
> similar.
>=20
> From "http://h18004.www1.hp.com/products/servers/proliantdl360/", I
> see that your systems are EMT64.  Are you running them in 64bit or
> 32bit?  What kernel version are you running?
>=20
> When you refer to the same problem, I assume you mean tx timeouts.
> How are you causing the error?
>=20
> I never fully fixed Richards issue, but I was able to get it working
> under light traffic.  I got side tracked, and have't looked at the
> problem in a little while.  Are you willing to try some debug patches?
>=20
> With your approval, I would like to CC the netdev mailing list
> (netdev@oss.sgi.com) on these e-mails.  netdev is the linux kernel
> network mailing list (incase you didn't already know).
>=20
> Thanks,
> Jon
>=20
> On 6/7/05, MOUNIER Emmanuel <Emmanuel.MOUNIER@rfo.fr> wrote:
> >
> >
> >
> > Hello.
> >
> >   I'm a french network manager, and I have a big problem with some Dl=
ink
> > Fiber Network cards (DGE-550SX).
> >
> >  I've seen on a website that you helped Mr Richard EMS to try to find=
 a
> > solution.
> > (http://www.ussg.iu.edu/hypermail/linux/kernel/0412.2/0371.html)
> >
> >  I've contacted him, but he said he have bought another Fiber NIC car=
d.
> >
> >  My problem is that I have 13 DGE-550SX cards for 8 HP Server Prolian=
t
> > DL-360 G4, and I have the same problem.
> >
> >  Just want to know if you have any idea now, or maybe, if you can bri=
ng me
> > some help...
> >
> >  Fiber NIC card is very expensive, and I hope I will find a way to so=
lve the
> > problem but, either DLink or HP seem to be able to give me a solution.
> >
> >  If I can do something to help you, just tell me what !
> >
> >  Thanks per advance.
> >
> >  Emmanuel Mounier
> >  Charg=E9 de projet direction Technique
> >  RFO ( www.rfo.fr )
> >  mail : emmanuel.mounier@rfo.fr
>=20
>=20
>=20
>
