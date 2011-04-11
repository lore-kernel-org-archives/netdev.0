From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: extending feature word.
Date: Mon, 11 Apr 2011 12:49:27 -0700
Message-ID: <20110411124927.572b3d04@nehalam>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com>
	<20110408100535.GB10565@rere.qmqm.pl>
	<BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
	<20110410101954.GA23753@rere.qmqm.pl>
	<BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com>
	<20110411115459.13ac3c73@nehalam>
	<20110411191947.GC31338@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53553 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534Ab1DKTtc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 15:49:32 -0400
In-Reply-To: <20110411191947.GC31338@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2011 21:19:47 +0200
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> On Mon, Apr 11, 2011 at 11:54:59AM -0700, Stephen Hemminger wrote:
> > On Mon, 11 Apr 2011 11:45:05 -0700
> > Mahesh Bandewar <maheshb@google.com> wrote:
> > > >> That is right! making it an array doesn't really buy us anythi=
ng
> > > >> unless there is a uniform way of managing all the bits spread =
across
> > > >> multiple words inside that array. This was the reason why I ha=
ve
> > > >> changed that array into a bitmap in the patch that I have post=
ed
> > > >> earlier. This way the upper limit (currently only 32 bits) wil=
l be
> > > >> removed and we'll have a long term solution. There will be lit=
tle bit
> > > >> of work involved but 'doing-things-right' has cost associated.=
 =20
> > > > I really don't like the bitmap idea. It multiplies the amount o=
f code
> > > > needed to manipulate multiple bits at once --- and that's a com=
mon
> > > > thing for drivers to do. Almost every driver that needs ndo_fix=
_features
> > > > will clear sets --- checkumming set, TSO set, all TX offloads s=
et, ...
> > > Should the added code be of any concern? If that is happening in =
the
> > > control-path and does not affect the data-path as such; those add=
ed
> > > instructions is a cost of added flexibility to we got through bit=
map.
> > > If performance is not at risk then that shouldn't be a problem.
> > Just to be dense... What is wrong with just using u64?
>=20
> Hmm. Looks like this is so simple that nobody thought of it seriously=
=2E ;)
>=20
> This of course needs a bit of glue code in G/SFEATURES handling, but =
most
> of the change would be s/u32/u64/ in apropriate places.

I am a strong proponent of not building stuff until it is needed.
  http://www.extremeprogramming.org/rules/early.html
By the time 64 bits are exhausted the existing model of network device
may have changed significantly anyway.
 =20
