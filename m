From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] x86/PCI: initialize PCI bus node numbers early
Date: Tue, 14 Jul 2009 08:47:31 -0700
Message-ID: <20090714084731.61d5d39d@jbarnes-g45>
References: <20090710104419.0032be7b@jbarnes-g45>
	<4A57A1FE.30609@kernel.org>
	<20090710132249.1a032cfb@jbarnes-g45>
	<20090710140654.32132bcb@jbarnes-g45>
	<4807377b0907140041y6c9da555lf3e1dba0775cfe7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org,
	NetDEV list <netdev@vger.kernel.org>, ak@linux.intel.com,
	matthew@wil.cx
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754910AbZGNPrg@vger.kernel.org>
In-Reply-To: <4807377b0907140041y6c9da555lf3e1dba0775cfe7c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Jul 2009 00:41:30 -0700
Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:

> On Fri, Jul 10, 2009 at 2:06 PM, Jesse
> Barnes<jbarnes@virtuousgeek.org> wrote:
> > From 2b51fba93f7b2dabf453a74923a9a217611ebc1a Mon Sep 17 00:00:00
> > 2001 From: Jesse Barnes <jbarnes@virtuousgeek.org>
> > Date: Fri, 10 Jul 2009 14:04:30 -0700
> > Subject: [PATCH] x86/PCI: initialize PCI bus node numbers early
> >
> > The current mp_bus_to_node array is initialized only by AMD specifi=
c
> > code, since AMD platforms have registers that can be used for
> > determining mode numbers. =C2=A0On new Intel platforms it's necessa=
ry to
> > initialize this array as well though, otherwise all PCI node number=
s
> > will be 0, when in fact they should be -1 (indicating that I/O isn'=
t
> > tied to any particular node).
> >
> > So move the mp_bus_to_node code into the common PCI code, and
> > initialize it early with a default value of -1. =C2=A0This may be
> > overridden later by arch code (e.g. the AMD code).
> >
> > With this change, PCI consistent memory and other node specific
> > allocations (e.g. skbuff allocs) should occur on the "current" node=
=2E
> > If, for performance reasons, applications want to be bound to
> > specific nodes, they should open their devices only after being
> > pinned to the CPU where they'll run, for maximum locality.
> >
> > Acked-by: Yinghai Lu <yinghai@kernel.org>
> > Tested-by: Jesse Brandeburg <jesse.brandeburg@gmail.com>
> > Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>
>=20
> I can confirm this works, aside from the MSI-X interrupt migration
> instability (panics) that I believe are unrelated since they happen
> without this patch.
>=20
> I also see a pretty nice performance boost by running with this chang=
e
> on a 5520 motherboard, with an 82599 10GbE forwarding packets, esp
> with interrupt affinity set correctly.
>=20
> I'd like to see this applied if at all possible, I think it is really
> hampering I/O traffic performance due to limiting all network (among
> others) memory allocation to one of the two numa nodes.

Ok, thanks for testing.  I've pushed it to my linux-next branch.

--=20
Jesse Barnes, Intel Open Source Technology Center
