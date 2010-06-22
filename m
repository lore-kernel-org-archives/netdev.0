From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34 Crash in dmaengine_put()
Date: Tue, 22 Jun 2010 16:43:24 +0200
Message-ID: <1277217804.3057.428.camel@edumazet-laptop>
References: <AANLkTilCW2iqsNaWM9NYIomy8OxGC9jG40KpLcKMYTqL@mail.gmail.com>
	 <20100621202854.de928e0a.akpm@linux-foundation.org>
	 <AANLkTimsDSrEL8vT877pLYSa4A338p4Y8w0Ya6Xm7BFJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeffrey Merkey <jeffmerkey@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimsDSrEL8vT877pLYSa4A338p4Y8w0Ya6Xm7BFJ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 22 juin 2010 =C3=A0 08:08 -0600, Jeffrey Merkey a =C3=A9crit :

Please dont top post on lkml (or netdev) messages

> OK.  This bug occurs if you OR in the IFF_UP flag while creating
> virtual interfaces without going through the normal ifup/ifdown
> scripts.  Looks like a hole.  I will post the trace shortly.  It's
> easy to reproduce, take the dummy net driver, OR in the IFF_UP flag i=
n
> dummy_setup, and watch the kernel crash.
>=20

Then dont do that ?

No need to send us a trace, unless you use a pristine kernel.

IFF_UP changes rules are very strict, dont try to avoid them and claim
there is a hole or something wrong.

Check __dev_open() , __dev_close() and __dev_change_flags() were OR/AND
IFF_UP is done by core network.

Net drivers are not allowed to change IFF_UP themselves.

(DE-600 & DE-620 being the exceptions to confirm this rule, of course)


> Jeff
>=20
> On Mon, Jun 21, 2010 at 9:28 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Mon, 21 Jun 2010 20:57:40 -0600 Jeffrey Merkey <jeffmerkey@gmail=
=2Ecom> wrote:
> >
> >> If someone sets the IFF_UP flags in the netdev structure without g=
oing
> >> through ifup userspace stuff, during unregister of the the netdev
> >> the dmaengine-put code will decrement the reference counter negati=
ve,
> >> and crash at BUG! in the driver/dma/dmaengine.c code.  This seems
> >> busted.
> >>
> >
> > Please send a copy of the kernel BUG trace.
> >
> -
