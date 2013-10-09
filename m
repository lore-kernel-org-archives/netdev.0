From: Dan Williams <dcbw@redhat.com>
Subject: Re: MBIM device refusing to be enabled
Date: Wed, 09 Oct 2013 08:31:32 -0500
Message-ID: <1381325492.1928.8.camel@dcbw.foobar.com>
References: <1381309180.3464.2.camel@linux-fkkt.site>
	 <871u3u21zz.fsf@nemi.mork.no> <87hacqzqi0.fsf@nemi.mork.no>
	 <87d2nezoob.fsf@nemi.mork.no> <1381317745.3464.6.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228Ab3JIN0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 09:26:12 -0400
In-Reply-To: <1381317745.3464.6.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-09 at 13:22 +0200, Oliver Neukum wrote:
> On Wed, 2013-10-09 at 13:09 +0200, Bj=C3=B8rn Mork wrote:
> > Bj=C3=B8rn Mork <bjorn@mork.no> writes:
>=20
> Hi,
>=20
> >=20
> > > Sorry, that was nonsense.  rfkill would only affect the HwRadioSt=
ate.
> >=20
> > Turns out I wasn't completely off anyway... by pure luck ;-)
> >=20
> > > Looking at the commands following this message, it appears that M=
M
> > > correctly attempts to enable the SwRadioState but fails.  I don't=
 know
> > > why.
>=20
> Cool.
>=20
> > Is the device by any chance a Sierra Wireless device?
>=20
> Yes. Rebranded by HP but it is Sierra.
> HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module
>=20
> > I was able to recreate the behaviour you see after experimenting a =
bit
> > with my MC7710.  This device (and I assume most other MBIM capable
> > Sierra Wireless minicards) can be configured to enter low power mod=
e on
> > rfkill (W_DISABLE asserted), instead of powering off.  Sony for exa=
mple
> > are known to configure the built-in Sierra devices in this mode.
> >=20
> > When low power mode is forced by rfkill this way, the firmware
> > erroneously[1] claims
> >=20
> >  HwRadioState: on
> >  SwRadioState: off
> >=20
> > Any attempt to change this software state using MBIM will fail with
> > MBIM_STATUS_FAILURE.  Exactly like your log shows.  The modem must =
be
> > enabled using rfkill before MM can use it. Changing the firmware
> > behaviour will not do any good - it will just cause the modem to po=
wer
> > off and disappear instead.
> >=20
> > So I would start looking at rfkill after all.  There are often prob=
lems
> > with these platform drivers and newer laptops, due to the lack of
> > documentation from the vendors.  Here's one (now fixed) example:
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D47751
>=20
> Thanks. A quick look shows that there's something wrong. There is no
> rfkill entry for the device. I am investigating.

PCIe minicard pinouts have a W_DISABLE# pin (row 1 pin 20, active low)
that kills the card.  If your machine grounds that PIN or mishandles it
somehow, and the card cares about that pin, then the card will show as
rfkilled.

I have cards that care: Samsung Y3300/Y3400, and most Ericsson devices.
The devices themselves show as rfkilled (either through QMI, AT
commands, etc) but you can't do anything about it unless you have a way
to float W_DISABLE.

So depending on your laptop's slot pinout and BIOS behavior, and whethe=
r
or not the rfkill driver correctly supports your laptop, you might be
out of luck.

Dan
