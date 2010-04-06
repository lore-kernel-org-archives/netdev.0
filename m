From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 19:00:33 +0200
Message-ID: <1270573233.2081.47.camel@edumazet-laptop>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35953 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757471Ab0DFRAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 13:00:42 -0400
Received: by bwz1 with SMTP id 1so94091bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 10:00:40 -0700 (PDT)
In-Reply-To: <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 avril 2010 =C3=A0 10:12 -0600, John Linn a =C3=A9crit :
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Monday, April 05, 2010 3:30 PM
> > To: John Linn
> > Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; grant.likely@s=
ecretlab.ca;
> > jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com; michal.sim=
ek@petalogix.com; John Tyner
> > Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driv=
er
> >=20
> > Le lundi 05 avril 2010 =C3=A0 15:11 -0600, John Linn a =C3=A9crit :
> > > This patch adds support for using the LL TEMAC Ethernet driver on
> > > non-Virtex 5 platforms by adding support for accessing the Soft D=
MA
> > > registers as if they were memory mapped instead of solely through=
 the
> > > DCR's (available on the Virtex 5).
> > >
> > > The patch also updates the driver so that it runs on the MicroBla=
ze.
> > > The changes were tested on the PowerPC 440, PowerPC 405, and the
> > > MicroBlaze platforms.
> > >
> > > Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> > > Signed-off-by: John Linn <john.linn@xilinx.com>
> > >
> > > ---
> >=20
> > > +/* Align the IP data in the packet on word boundaries as MicroBl=
aze
> > > + * needs it.
> > > + */
> > > +
> > >  #define XTE_ALIGN       32
> > > -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN=
)
> > > +#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
> > >
> >=20
> > Very interesting way of doing this, but why such convoluted thing ?
>=20
> This is trying to align for a cache line (32 bytes) before my change.
>=20
> My change was then also making it align the IP data on a word boundar=
y.=20
>=20
> >=20
> > Because of the % 32, this is equivalent to :
> >=20
> > #define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)
> >=20
>=20
> Yes, but I'm not sure that's clearer IMHO.
>=20
> > But wait, dont we recognise the magic constant NET_IP_ALIGN ?
>=20
> Yes it could be used.  I'm struggling with how to make this all be cl=
earer.
>=20

I am not saying its clearer, I am saying we have a standard way to
handle this exact problem (aligning rcvs buffer so that IP header is
aligned)

There is no need to invent new ones, this makes reviewing of this drive=
r
more difficult.


> How about this?
> #define BUFFER_ALIGN(adr) (((XTE_ALIGN + NET_IP_ALIGN) - ((u32) adr))=
 % XTE_ALIGN)
>=20

Sorry, I still dont understand why you need XTE_ALIGN + ...

((A + B) - C) % A   is equal to (B - C) % A

Which one is more readable ?

Please take a look at existing and clean code, no magic macro, and we
can understand the intention.

find drivers/net | xargs grep -n netdev_alloc_skb_ip_align


