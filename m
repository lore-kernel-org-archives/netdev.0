From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Thu, 19 Jul 2007 18:28:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707191813490.5581@localhost.localdomain>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org>
 <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
 <20070718210903.GM3801@stusta.de> <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
 <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
 <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
 <20070719083109.13b2ab56.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
 <469FE045.3070403@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>, Jeff Garzik <jeff@garzik.org>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:44396 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbXGSWcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 18:32:10 -0400
In-Reply-To: <469FE045.3070403@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007, Simon Arlott wrote:

> On 19/07/07 17:19, Robert P. J. Day wrote:
> > On Thu, 19 Jul 2007, Randy Dunlap wrote:
> >> I think that Stefan means a patch to the kconfig source code,
> >> not the the Kconfig files.  Good luck.  I'd still like to see it.
> >
> > yes, i understand what he wanted now.  as a first step (that
> > theoretically shouldn't change any behaviour), i'd patch the Kconfig
> > structure to add a new attribute ("maturity") which would be allowed
> > to be set to *exactly one* of a pre-defined set of values (say,
> > OBSOLETE, DEPRECATED, EXPERIMENTAL, and STILLBLEEDING).  and that's
> > it, nothing more.
> >
> > don't try to do anything with any of that just yet, just add the
> > infrastructure to support the (optional) association of a maturity
> > level with a config option.  that's step one.
>
> What about something like this? I'm not sure if the addition to sym_init
> is desirable... I also had to prefix _ to the name for now otherwise it
> conflicts badly with the current symbols. It probably should stop
> "depends on _BROKEN" etc. too.
>
> ---
> diff --git a/init/Kconfig b/init/Kconfig
> diff --git a/net/Kconfig b/net/Kconfig
> index cdba08c..5e2f4db 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -6,6 +6,7 @@ menu "Networking"
>
>  config NET
>  	bool "Networking support"
> +	maturity _BROKEN

just as a bit of a digression, "BROKEN" is not what i would call a
maturity level, and i would explicitly *not* allow that as a possible
maturity because that just makes a mess of the design.

i specifically wanted to define a maturity level so that any feature
could be categorized as belonging to *at most* one maturity level.
that is, you can't be both EXPERIMENTAL and DEPRECATED at the same
time -- that just makes no sense.

once you tag some features with a maturity level, then part of the
build would involve selecting which subset of maturity levels you
wanted to see.  by default, you'd get to see those features that
weren't tagged at all, but you might also make a selection like this:

  [*] EXPERIMENTAL
  [*] DEPRECATED
  [ ] OBSOLETE

in other words, you wanted the choice of stuff in the first two
categories, but not the third.  (you would, of course, always get to
choose from non-tagged stuff, which would be your *normal* content,
exactly as it is now).

so what about BROKEN?  i would invent a whole new attribute for that,
called maybe "status":

config FUBAR
	depends on ...
	maturity DEPRECATED
	status BROKEN
	...

"status" is a totally orthogonal attribute to maturity.  status might
be one of BROKEN, BROKEN_ON_SMP, FLAKEY_AS HELL, etc.  and, once
again, any feature can fall into *at most* one status category.  once
you have the infrastructure to support a single attribute like
maturity, you get any additional ones for free.  and rather than
defining all those things as simple dependencies, by creating new
objects called "attributes", you can play all sorts of interesting new
games, and the attribute infrastructure can enforce that you're using
it properly.

now i'll go away and read the rest of your post.  :-)

rday

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
