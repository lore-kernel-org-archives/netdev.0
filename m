From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: Panic at tcp_xmit_retransmit_queue
Date: Thu, 18 Feb 2010 11:28:26 +0100
Message-ID: <20100218112826.39aabf85@pluto.restena.lu>
References: <53cc795f1001190813m377c6c91l16b2dc04f63049e7@mail.gmail.com>
 <53cc795f1002010645w54b98b51s3dbdea18e5eb73f2@mail.gmail.com>
 <alpine.DEB.2.00.1002031258160.7063@wel-95.cs.helsinki.fi>
 <alpine.DEB.2.00.1002151520250.7063@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sbs <gexlie@gmail.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1002151520250.7063@wel-95.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Feb 2010 15:21:58 "Ilpo J=C3=A4rvinen" wrote:
> On Wed, 3 Feb 2010, Ilpo J=C3=A4rvinen wrote:
>=20
> > On Mon, 1 Feb 2010, sbs wrote:
> >=20
> > > actually removing netconsole from kernel didnt help.
> > > i found many guys with the same problem but with different
> > > hardware configurations here:
> > >=20
> > > freez in TCP stack :
> > > http://bugzilla.kernel.org/show_bug.cgi?id=3D14470
> > >=20
> > > is there someone who can investigate it?
> > >=20
> > >=20
> > > On Tue, Jan 19, 2010 at 7:13 PM, sbs <gexlie@gmail.com> wrote:
> > > > We are hiting kernel panics on servers with nVidia MCP55 NICs
> > > > once a day; it appears usualy under a high network trafic
> > > > ( around 10000Mbit/s) but it is not a rule, it has happened
> > > > even on low trafic.
> > > >
> > > > Servers are used as nginx+static content
> > > > On 2 equal servers this panic happens aprox 2 times a day
> > > > depending on network load. Machine completly freezes till the
> > > > netconsole reboots.
> > > >
> > > > Kernel: 2.6.32.3
> > > >
> > > > what can it be? whats wrong with tcp_xmit_retransmit_queue()
> > > > function ? can anyone explain or fix?
> >=20
> > You might want to try with to debug patch below. It might even make
> > the box to survive the event (if I got it coded right).
>=20
> Here should be a better version of the debug patch, hopefully the
> infinite looping is now gone.

I can reproduce the freeze pretty easily, even on an idle server,
all I need is netconsole enabled, an ssh connection to server and
permission to write to /proc/sysrq-trigger.

The following command, executed via SSH triggers the frozen system:
  echo t > /proc/sysrq-trigger
when netconsole is enabled. Doing the same from local console has no
negative effect (idle system).
Unfortunately I can't get any useful information out of the system as
nothing reaches VGA console and interaction with the system is not
possible anymore (cursor is still blinking on VGA console).

Unfortunately I currently have no setup here to analyze dead system via
kexec crash kernel that would be run on watchdog.

System I'm using is HP Proliant DL360 G5 (4 logical CPUs, two sockets),
bnx2 NIC.
Eventually I will try with some other system to reproduce there as
well (to rule out NIC driver).

Any hints on how to get pertinent data out of that system would be
really nice!

Regards,
Bruno
