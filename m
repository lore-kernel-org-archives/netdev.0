From: Joseph Golio <golio@vieo.com>
Subject: Re: [Fwd: IPoIB]
Date: Thu, 06 Jun 2002 14:14:42 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CFFB4A2.E9FC09FC@vieo.com>
References: <Pine.GSO.4.05.10205301751370.9848-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jeff young <jsy@vieo.com>,
   gary klesk <gklesk@vieo.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org

Thomas 'Dent' Mirlacher wrote:

Thomas,

    Thanks for the reply. The more I dig into this, the more I figure out that the
problem is larger than I though. Not only do I need to increase the size of a
hardware address, I also need to provide a new interface service routine to allow
the device driver to lookup/translate a portion of the hardware address  and return
more information that needs to go into the ARP cache.

Specifically, the IETF IPoIB group has defined an Infiniband hardware address to
have 1 byte of reserved, 3 bytes of Queue Pair Number (QPN) and 16 bytes of
Global Identifier (GID). Unfortunately, in order to build the hardware header
in packets to send, another piece of information is needed -- that being the Local
Identifier (LID). If the LID is kept in the ARP cache, then it will be readily
available
from "arp_find()" at the time of transmission. If we don't do that, we would have to
have a separate table and mechanism in the driver to map from QPN/GID ===> LID.
I would rather not do that if I didn't have to. It seems fundamental (at least to me)
that
everything one needs to build the hardware header  (at least everything that is
related
specifically to the destination) should be stored in the ARP cache.

Thoughts  anyone ?

Thanks,

Joe

> --snip/snip
>
> > >     I have a question. I am working on developing a Linux driver for IP over
> > > Infiniband (IPoIB) and
> > >     have run into an issue that I need your advice. The draft standard from the
> > > IETF on IPoIB
> > >     encapsulation and address resolution over Infiniband networks (see the link
> > > below - section 6.1.1)
> > >     defines the hardware address as being 20 bytes in length. It appears that
> > > the "netdevice.h" file in
> > >     Linux has MAX_ADDR_LEN set to 7 (at least in my version which is SuSe 7.3 -
>
> for 2.5.18 at least it's set to 8, but there is no reason to not change it to
> 20 beside wasting some memory
>
> n time for
>         a) broadcast address
>         b) device address
>         int netdevice
> sum(m[n]) times for the multicast list
>
> where n == number of network devices, m == number of MC entries per device
> as i can see it.
>
> and this "overhead" should be really acceptable :)
>
> ... probably you will break some "external" stuff like freeswan, but this
> shouldn't be your problem.
>
>         tm
>
> --
> in some way i do, and in some way i don't.
