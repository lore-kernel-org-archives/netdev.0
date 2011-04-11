From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: extending feature word.
Date: Mon, 11 Apr 2011 21:19:47 +0200
Message-ID: <20110411191947.GC31338@rere.qmqm.pl>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com> <20110408100535.GB10565@rere.qmqm.pl> <BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com> <20110410101954.GA23753@rere.qmqm.pl> <BANLkTimFzTGKmhfRxzEUt_LwrnhAaetU5Q@mail.gmail.com> <20110411115459.13ac3c73@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51056 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753923Ab1DKTTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 15:19:49 -0400
Content-Disposition: inline
In-Reply-To: <20110411115459.13ac3c73@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2011 at 11:54:59AM -0700, Stephen Hemminger wrote:
> On Mon, 11 Apr 2011 11:45:05 -0700
> Mahesh Bandewar <maheshb@google.com> wrote:
> > >> That is right! making it an array doesn't really buy us anything
> > >> unless there is a uniform way of managing all the bits spread ac=
ross
> > >> multiple words inside that array. This was the reason why I have
> > >> changed that array into a bitmap in the patch that I have posted
> > >> earlier. This way the upper limit (currently only 32 bits) will =
be
> > >> removed and we'll have a long term solution. There will be littl=
e bit
> > >> of work involved but 'doing-things-right' has cost associated. =20
> > > I really don't like the bitmap idea. It multiplies the amount of =
code
> > > needed to manipulate multiple bits at once --- and that's a commo=
n
> > > thing for drivers to do. Almost every driver that needs ndo_fix_f=
eatures
> > > will clear sets --- checkumming set, TSO set, all TX offloads set=
, ...
> > Should the added code be of any concern? If that is happening in th=
e
> > control-path and does not affect the data-path as such; those added
> > instructions is a cost of added flexibility to we got through bitma=
p.
> > If performance is not at risk then that shouldn't be a problem.
> Just to be dense... What is wrong with just using u64?

Hmm. Looks like this is so simple that nobody thought of it seriously. =
;)

This of course needs a bit of glue code in G/SFEATURES handling, but mo=
st
of the change would be s/u32/u64/ in apropriate places.

Best Regards,
Micha=B3 Miros=B3aw
