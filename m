From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Sat, 1 Sep 2007 08:56:30 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709010853040.6031@localhost.localdomain>
References: <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
 <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
 <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
 <20070719083109.13b2ab56.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
 <469FE045.3070403@simon.arlott.org.uk> <20070831102527.09fb42c0.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0709010641540.31472@localhost.localdomain>
 <20070901124901.GA2935@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:39024 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbXIANJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 09:09:35 -0400
In-Reply-To: <20070901124901.GA2935@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 1 Sep 2007, Sam Ravnborg wrote:

> On Sat, Sep 01, 2007 at 06:44:06AM -0400, Robert P. J. Day wrote:
> >
> > > >  	while (1) {
> > > >  		printf("%*s%s ", indent - 1, "", menu->prompt->text);
> > > > +		switch (sym->maturity) {
> > > > +		case M_EXPERIMENTAL:
> > > > +			printf("(EXPERIMENTAL) ");
> > > > +			break;
> > > > +		case M_DEPRECATED:
> > > > +			printf("(DEPRECATED) ");
> > > > +			break;
> > > > +		case M_OBSOLETE:
> > > > +			printf("(OBSOLETE) ");
> > > > +			break;
> > > > +		case M_BROKEN:
> > > > +			printf("(BROKEN) ");
> > > > +			break;
> > > > +		default:
> > > > +			break;
> > > > +		}
> > > >  		if (sym->name)
> > > >  			printf("(%s) ", sym->name);
> > > >  		type = sym_get_type(sym);
> >
> > for now, simon, why not just reduce this to supporting only DEPRECATED
> > and OBSOLETE so that it can be at least tested as "proof of concept?"
>
> The principle with letting a dependency add text to the promts are good.
> But the implementation done by Simon with a language extension is not good.
> A simple and better approach would be to use the newly added option
> support for this and let the backend generate the promtps.
>
> I have not yet tried to cook up a patch for it, but it should be
> quite generaic and doable.
>
> config EXPERIMENTAL
> 	option appendprompt=" (EXPERIMENTAL)
>
> config DEPRECATED
> 	option appendprompt=" (DEPRECATED)


but this is deviating from the basic principle that these things are
not regular Kconfig "config" settings -- they are a new beast
entirely, and need a new infrastructure to support them.

put another way, they are not a normal kernel feature to be selected
or deselected.  they are, rather, *attributes* that can be *applied*
to kernel features, in the same way as is done with "bool" or
"string".  making these things regular config directives defeats the
whole purpose.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
