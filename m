From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH net-next-2.6] net: dev_addr_init() fix
Date: Mon, 8 Jun 2009 15:06:53 +0200
Message-ID: <20090608130653.GB3272@elte.hu>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com> <1244408607.9064.8.camel@Maple> <19f34abd0906080300w796c6b65o6b537064cac917b0@mail.gmail.com> <4A2CEB9E.7080109@gmail.com> <4A2D006C.70302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Dykstra <john.dykstra1@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755113AbZFHNHT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A2D006C.70302@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =E9crit :
> > Vegard Nossum a =E9crit :
> >> 2009/6/7 John Dykstra <john.dykstra1@gmail.com>:
> >>> On Sat, 2009-05-30 at 22:23 +0200, Vegard Nossum wrote:
> >>>> It seems that loopback's hardware address is never initialized b=
y the
> >>>> kernel. So if userspace attempts to read this address before it =
has
> >>>> been set, the kernel will return some uninitialized data (only 6
> >>>> bytes, though).
> >>> Thank you for the report, Vegard.
> >>>
> >>> I've been unable to reproduce the problem you describe, using
> >>> 2.6-30-rc8, this test program and a couple of kernel builds for s=
ystem
> >>> load:
> >> [...]
> >>> -----------------------------------------------------------------=
-
> >>>
> >>> Looking at the kernel code, it appears that all bytes of struct
> >>> net_device, including the L2 address, are initialized to zeros at
> >>> interface creation time.
> >>>
> >>> Can you spot a difference between your test procedures and mine t=
hat
> >>> would enable me to reproduce the problem?
> >> Hi,
> >>
> >> I just tried your test program on a linux-next kernel, it works be=
autifully :-)
> >>
> >> (I made one change: The stack grows downwards on x86, so I think y=
ou
> >> should put child_stack + 16386 as the stack to clone()?)
> >>
> >> As I wrote in reply to Stephen Hemminger, this problem seems to be
> >> caused by a particular patch in linux-next:
> >>
> >> commit f001fde5eadd915f4858d22ed70d7040f48767cf
> >> Author: Jiri Pirko <jpirko@redhat.com>
> >> Date:   Tue May 5 02:48:28 2009 +0000
> >>
> >>    net: introduce a list of device addresses dev_addr_list (v6)
> >>
> >=20
> > I believe following patch should fix this problem.
> >=20
> > Thank you
> >=20
> > [PATCH net-next-2.6] net: loopback device dev->addr_len fix
> >=20
> > commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
> > (net: introduce a list of device addresses dev_addr_list (v6))
> > added one regression Vegard Nossum found in its testings.
> >=20
> > loopback device doesnt have a hw address, we should set its
> > dev->addr_len to 0, not ETH_ALEN.
> >=20
> > Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Oh well, following is probably even more appropriate
>=20
> [PATCH net-next-2.6] net: dev_addr_init() fix
>=20
> commit f001fde5eadd915f4858d22ed70d7040f48767cf=20
> (net: introduce a list of device addresses dev_addr_list (v6))
> added one regression Vegard Nossum found in its testings.
>=20
> dev_addr_init() incorrectly uses sizeof() operator
>=20
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Could you please put the word 'kmemcheck' somewhere into the=20
changelog, to make git-grepping and historic comparisons easier?

Thanks,

	Ingo
