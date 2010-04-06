From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 6 Apr 2010 14:03:38 -0600
Message-ID: <86f149a4-088a-4c37-ba6f-a49dbc9acbeb@VA3EHSMHS033.ehs.local>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local> <1270502993.9013.36.camel@edumazet-laptop> <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local> <1270573233.2081.47.camel@edumazet-laptop> <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local> <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>, <michal.simek@petalogix.com>,
	"John Tyner" <jtyner@cs.ucr.edu>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.15]:25448
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754649Ab0DFUFT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Apr 2010 16:05:19 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of=
 Grant Likely
> Sent: Tuesday, April 06, 2010 12:54 PM
> To: John Linn
> Cc: Eric Dumazet; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; jw=
boyer@linux.vnet.ibm.com;
> john.williams@petalogix.com; michal.simek@petalogix.com; John Tyner
> Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
>=20
> On Tue, Apr 6, 2010 at 11:11 AM, John Linn <John.Linn@xilinx.com> wro=
te:
> >> -----Original Message-----
> >> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >> Sent: Tuesday, April 06, 2010 11:01 AM
> >> To: John Linn
> >> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; grant.likely@=
secretlab.ca;
> >> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com; michal.si=
mek@petalogix.com; John Tyner
> >> Subject: RE: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC dri=
ver
> >>
> >> Le mardi 06 avril 2010 =E0 10:12 -0600, John Linn a =E9crit :
> >> > > -----Original Message-----
> >> > > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >> > > Sent: Monday, April 05, 2010 3:30 PM
> >> > > To: John Linn
> >> > > Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; grant.lik=
ely@secretlab.ca;
> >> > > jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com; micha=
l.simek@petalogix.com; John Tyner
> >> > > Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC=
 driver
> >> > >
> >> > > Le lundi 05 avril 2010 =E0 15:11 -0600, John Linn a =E9crit :
> >> > > > This patch adds support for using the LL TEMAC Ethernet driv=
er on
> >> > > > non-Virtex 5 platforms by adding support for accessing the S=
oft DMA
> >> > > > registers as if they were memory mapped instead of solely th=
rough the
> >> > > > DCR's (available on the Virtex 5).
> >> > > >
> >> > > > The patch also updates the driver so that it runs on the Mic=
roBlaze.
> >> > > > The changes were tested on the PowerPC 440, PowerPC 405, and=
 the
> >> > > > MicroBlaze platforms.
> >> > > >
> >> > > > Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> >> > > > Signed-off-by: John Linn <john.linn@xilinx.com>
> >> > > >
> >> > > > ---
> >> > >
> >> > > > +/* Align the IP data in the packet on word boundaries as Mi=
croBlaze
> >> > > > + * needs it.
> >> > > > + */
> >> > > > +
> >> > > > =A0#define XTE_ALIGN =A0 =A0 =A0 32
> >> > > > -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_=
ALIGN)
> >> > > > +#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
> >> > > >
> >> > >
> >> > > Very interesting way of doing this, but why such convoluted th=
ing ?
> >> >
> >> > This is trying to align for a cache line (32 bytes) before my ch=
ange.
> >> >
> >> > My change was then also making it align the IP data on a word bo=
undary.
> >> >
> >> > >
> >> > > Because of the % 32, this is equivalent to :
> >> > >
> >> > > #define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)
> >> > >
> >> >
> >> > Yes, but I'm not sure that's clearer IMHO.
> >> >
> >> > > But wait, dont we recognise the magic constant NET_IP_ALIGN ?
> >> >
> >> > Yes it could be used. =A0I'm struggling with how to make this al=
l be clearer.
> >> >
> >>
> >> I am not saying its clearer, I am saying we have a standard way to
> >> handle this exact problem (aligning rcvs buffer so that IP header =
is
> >> aligned)
> >>
> >> There is no need to invent new ones, this makes reviewing of this =
driver
> >> more difficult.
>=20
> Hold on.... BUFFER_ALIGN is being used to align the DMA buffer on a
> cache line boundary.  I don't think netdev_alloc_skb() makes any
> guarantees about how the start of the IP header lines up against cach=
e
> line boundaries.  The amount of padding needed is not known until an
> skbuff is obtained from netdev_alloc_skb(), and
> netdev_alloc_skb_ip_align() can only handle a fixed size padding,
>=20
> It doesn't look like netdev_alloc_skb_ip_align() is the right thing i=
n
> this regard.
>=20
> >> > How about this?
> >> > #define BUFFER_ALIGN(adr) (((XTE_ALIGN + NET_IP_ALIGN) - ((u32) =
adr)) % XTE_ALIGN)
> >> >
> >>
> >> Sorry, I still dont understand why you need XTE_ALIGN + ...
> >>
> >> ((A + B) - C) % A =A0 is equal to (B - C) % A
> >>
> >> Which one is more readable ?
> >
> > I'm fine with your suggestion.
> >
> > #define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)
> >
> >>
> >> Please take a look at existing and clean code, no magic macro, and=
 we
> >> can understand the intention.
> >>
> >> find drivers/net | xargs grep -n netdev_alloc_skb_ip_align
> >>
> >>
> >
> > Yes I see how it's used, but it only allows you to reserve 2 bytes =
in the skb with no options.
>=20
> Eric is here.  The mod operation means that BUFFER_ALIGN using either
> 2 or 34 is equivalent.
>=20
> g.

I can spin another patch with the following and with Grant's Kconfig ch=
anges, just looking for confirmation that's acceptable.

#define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)

Thanks,
John




This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and contain(s) confidential information that may be pro=
prietary, privileged or copyrighted under applicable law. If you are no=
t the intended recipient, do not read, copy, or forward this email mess=
age or any attachments. Delete this email message and any attachments i=
mmediately.


