From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 11:14:58 -0400
Message-ID: <20080526111458.fff6c311.billfink@mindspring.com>
References: <482C7E53.3050300@hp.com>
	<482C8184.2030906@garzik.org>
	<482C8550.5000909@intel.com>
	<482C8D4D.3040702@garzik.org>
	<20080516132107.GA11304@csclub.uwaterloo.ca>
	<20080516161029.44ded734@core>
	<20080516173610.GA27126@csclub.uwaterloo.ca>
	<20080516191125.46f59ad6@core>
	<a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com>
	<1211728189.5913.71.camel@andromache>
	<20080525232712.GF5970@mit.edu>
	<20080526154326.1fe44214@Varda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Tso <tytso@MIT.EDU>, Glen Turner <gdt@gdt.id.au>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alejandro Riveira =?ISO-8859-1?Q?Fern=E1ndez?=
	<ariveira@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:44359 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbYEZPPU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 11:15:20 -0400
In-Reply-To: <20080526154326.1fe44214@Varda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008, Alejandro Riveira Fern=E1ndez wrote:

> El Sun, 25 May 2008 19:27:12 -0400
> Theodore Tso <tytso@MIT.EDU> escribi=F3:
>=20
> > On Mon, May 26, 2008 at 12:39:49AM +0930, Glen Turner wrote:
> > >=20
> > > For example, /dev/random has run out. So the output of /dev/urand=
om
> > > is now determined by previous values of /dev/random.  I then send=
 in
> > > a stack of network packets at regular intervals. So the output of
> > > /dev/urandom is now greatly determined by those packets.  My sear=
ch
> > > space for the resulting key is small since /dev/urandom appears t=
o
> > > be random, but in fact is periodic.
> >=20
> > That's not how it works.  Basically, as long as there is *some*
> > entropy in the system, even from the /var/lib/random-seed, or from
> > keyboard interrupts, or from mouse interrupts, which is unknown to =
the
> > attacker, in the worse case /dev/urandom will be no worse than a
> > cryptographic random number generator.
> >=20
>  [ ... ]=20
> =20
>  Just a shot in the dark... would hw sensors (raw data) chips be a go=
od source
>  of entropy for /dev/random ??=20

=46or systems with high resolution timers, even if an attacker has tota=
l
knowledge/control of the network, it doesn't seem realistically possibl=
e
for them to determine the low order bits of the nanosecond timer of
disk and network I/O system calls, if those were used as a source of
entropy.  I think this is a case of the (unrealistic) best being an
enemy of the common (and realistic) good.

Another idea that occured to me:  How about using the low order bits
of the instruction memory address being executed that was interrupted
by the HZ timer interrupt.  This also doesn't seem to be something
that an external attacker could realistically determine.  And a
combination of these approaches would be that much stronger, combined
of course with any other available entropy sources.

						-Bill

