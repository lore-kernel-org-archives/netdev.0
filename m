From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: Section conflict compile failures in net
Date: Sat, 18 Jun 2011 19:06:20 +0200
Message-ID: <20110618170620.GA10479@rere.qmqm.pl>
References: <1306445993.4048.58.camel@mulgrave.site>
 <20110531.154531.493226762.davem@davemloft.net>
 <1306892570.11897.35.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47826 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844Ab1FRRGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jun 2011 13:06:22 -0400
Content-Disposition: inline
In-Reply-To: <1306892570.11897.35.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2011 at 10:42:50AM +0900, James Bottomley wrote:
> On Tue, 2011-05-31 at 15:45 -0700, David Miller wrote:
> > From: James Bottomley <James.Bottomley@HansenPartnership.com>
> > Date: Thu, 26 May 2011 16:39:53 -0500
> >=20
> > BTW, linux-netdev doesn't exist, it's just plain netdev.
>=20
> Um, yes ... I thought it was netdev, then I checked MARC and it had
> linux-netdev.  I'll remember for next time (well, at least for the ne=
xt
> six months).
>=20
> > > Simply reverting=20
> > >=20
> > > commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4
> > > Author: Micha<C5><82> Miros<C5><82>aw <mirq-linux@rere.qmqm.pl>
> > > Date:   Mon Apr 18 13:31:20 2011 +0000
> > >=20
> > >     net: fix section mismatches
> > >    =20
> > > Fixes the problem.
> > >=20
> > > If I look at the first problem in hp100.c, the addition of
> > > __devinitconst to the device tables is fine, but there's no
> > > corresponding sectional tag on their use, so when compiled as a m=
odule,
> > > things like hp100_eisa_driver is now in the main data section but=
 refers
> > > to something in the init data section ... I assume all the others=
 are
> > > the same type of problem.
> >=20
> > Yeah I think the device ID table __devinitconst bits have to be
> > reverted.
> >=20
> > I'll apply something like the following:
> >=20
> > net: Revert adding __devinitconst to driver ID tables.
> >=20
> > If the table is hooked up to foo_driver->id_table we can't
> > mark it __devinitconst otherwise we end up with section
> > mismatches.
> >=20
> > Reported-by: James Bottomley <James.Bottomley@HansenPartnership.com=
>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> That fixes some but not all; the pci tables still cause a section
> conflict:
>=20
> drivers/net/hp100.c:211: error: hp100_pci_tbl causes a section type c=
onflict
> make[2]: *** [drivers/net/hp100.o] Error 1
>=20
>=20
> It's really, as has been said, a compiler problem: the compiler is
> confused about the read only sections.  However, 4.2 is a pretty comm=
on
> compiler (especially for non-x86), so if the compiler can't do the re=
ad
> only section tracking, just not using the __devinitconst designation
> globally seems to be the best thing, just change it to __devinitdata
> instead.

So maybe just #define __devinitconst __devinitdata for those broken gcc
versions?

Best Regards,
Micha=B3 Miros=B3aw
