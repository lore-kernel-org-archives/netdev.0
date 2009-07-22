From: Bill Fink <billfink@mindspring.com>
Subject: Re: Constantly varying download rate with a complex xen networking
 setup, why?
Date: Tue, 21 Jul 2009 23:40:26 -0400
Message-ID: <20090721234026.4dd65318.billfink@mindspring.com>
References: <20090615075313.GA22819@rivendell>
	<Pine.LNX.4.64.0906151657380.16408@melkinkari.cs.Helsinki.FI>
	<20090615160254.GA8550@rivendell>
	<Pine.LNX.4.64.0906151910220.16408@melkinkari.cs.Helsinki.FI>
	<20090617130050.GA18586@rivendell>
	<Pine.LNX.4.64.0906171659380.31880@melkinkari.cs.Helsinki.FI>
	<20090617143647.GD18586@rivendell>
	<alpine.DEB.2.00.0907211143100.10534@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Raphael Hertzog <raphael@ouaza.com>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q? "Ilpo_J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:58596 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755933AbZGVDkf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 23:40:35 -0400
In-Reply-To: <alpine.DEB.2.00.0907211143100.10534@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jul 2009, Ilpo J=E4rvinen wrote:

> On Wed, 17 Jun 2009, Raphael Hertzog wrote:
>=20
> > Le mercredi 17 juin 2009, Ilpo J=E4rvinen a =E9crit :
> >> On Wed, 17 Jun 2009, Raphael Hertzog wrote:
> >>
> >>> Le lundi 15 juin 2009, Ilpo J=E4rvinen a =E9crit :
> >>>> Maybe the proxy interferes there somehow... I don't know enough =
about the
> >>>> details to say but I suppose the proxy at least breaks your tcp =
connection
> >>>> to two parts.
> >>>
> >>> Indeed. Is there some processing done in a simple linux bridge wh=
ere the
> >>> reapperance of the same TCP packet that has been created and sent=
 on another
> >>> local interface could create problem?
> >>
> >> I thought out had a http proxy in between? I suppose it is certain=
ly doing
> >> more than bridging. Anyway, I'll be week away, so no quick respons=
es are
> >> to be expected from my part after this mail.
> >
> > Well, I have the problem when I don't use the proxy... if I use it,=
 the
> > download is split over two TCP connections and things are fine.
> >
> > Hence my question was if something could be confused by the fact th=
at the
> > same packet is seen twice on the same machine once (in output) via=20
> > eth2/xenbrD and once (in forward) via xenbrE (the routing between b=
oth=20
> > bridges is done by the domU independently of the dom0 network confi=
g).
>=20
> Did you ever get tcpdumps btw? Looking into your setup it would proba=
bly=20
> be useful take it from all the interfaces where the packets are suppo=
sed=20
> to pass.

I don't know if the following has any applicability to your specific
situation, but I thought I'd mention it.

It has to do with what I call the non-transitivity of TCP network
performance.  If you have something like the following scenario:

	A <----LAN----> B <----WAN----> C
	     low RTT        high RTT

Just because you have good TCP network performance from A to B, and
good TCP network performance from B to C, it does not necessarily
follow that you will also have good TCP network performance from A to C=
=2E

Consider the case where the B<->C path is clean, but there are problems
on the A<->B path (causing TCP retransmissions).  The low RTT on the
A<->B path can mask the problems (basically TCP performs well in spite
of the problems because of the low RTT), but a transfer directly from
A to C performs poorly because the high RTT results in a very slow
ramp up in performance after a loss event.

Again, I have no idea if this applies in any way to your case.

						-Bill
