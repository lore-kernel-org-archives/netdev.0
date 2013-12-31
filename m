From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH 4/11] use ether_addr_equal_64bits
Date: Tue, 31 Dec 2013 08:26:47 +0200
Message-ID: <CANUX_P0PX1g8uHJUHYoB4UyMMgbtLas0_pf4TYrLTgND5V37rg@mail.gmail.com>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	<1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
	<1388429761.4410.1.camel@jlt4.sipsolutions.net>
	<alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
	<1388438724.4573.2.camel@jlt4.sipsolutions.net>
	<20131230215701.GA4938@khazad-dum.debian.net>
	<1388445188.18164.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:48396 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3LaG0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 01:26:49 -0500
In-Reply-To: <1388445188.18164.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 1:13 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
> On Mon, 2013-12-30 at 19:57 -0200, Henrique de Moraes Holschuh wrote:
> > On Mon, 30 Dec 2013, Johannes Berg wrote:
> > > On Mon, 2013-12-30 at 20:58 +0100, Julia Lawall wrote:
> > > > > Is there any way we could catch (sparse, or some other script?) that
> > > > > struct reorganising won't break the condition needed ("within a
> > > > > structure that contains at least two more bytes")?
> > > >
> > > > What kind of reorganizing could happen?  Do you mean that the programmer
> > > > might do at some time in the future, or something the compiler might do?
> > >
> > > I'm just thinking of a programmer, e.g. changing a struct like this:
> > >
> > >  struct foo {
> > >    u8 addr[ETH_ALEN];
> > > -  u16 dummy;
> > >  };
> > >
> > > for example.
> >
> > That is easily resolved by:
> >
> > struct foo {
> >       u8 addr[ETH_ALEN];
> >       u16 required_padding;   /* do not remove upon pain of death */
> > };
>
> That'd be a stupid waste of struct space. If anything, there should be
> *only* a comment saying that at least two bytes are needed - I'd still
> prefer an automated check.
>

Frankly I am not sure I like the patch. This flow is not a fast path
at all. While I don't really care for the waste in iwlwifi (because
there isn't), I don't see the real point is make the code more
sensitive to changes to earn basically nothing.

This flow happens only upon association which means a few times an hour maybe...
The only advantage I see here is that people like me who don't always
have a chance to read / write much code outside their little tiny
boring driver get to know about this kind of things. So, from an
educational point of view - this is cool.
But education is one thing, and the code is another.
