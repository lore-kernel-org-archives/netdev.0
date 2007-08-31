From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Fri, 31 Aug 2007 13:16:12 -0700
Message-ID: <20070831131612.312664ef.rdunlap@xenotime.net>
References: <469E75AA.7040109@pimpmylinux.org>
	<Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
	<20070718134012.cde2f956.randy.dunlap@oracle.com>
	<469E7BE1.6090401@garzik.org>
	<Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
	<20070718210903.GM3801@stusta.de>
	<Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
	<20070719054742.GN3801@stusta.de>
	<Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
	<469F240E.9040205@s5r6.in-berlin.de>
	<Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
	<20070719083109.13b2ab56.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
	<469FE045.3070403@simon.arlott.org.uk>
	<20070831102527.09fb42c0.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0708311318220.18158@localhost.localdomain>
	<46D858A9.4080506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Robert P. J. Day" <rpjday@mindspring.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Simon Arlott <simon@fire.lp0.eu>, sam@ravnborg.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:47491 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753619AbXHaUQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 16:16:13 -0400
Received: from midway.site ([96.225.192.201]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 13:16:13 -0700
In-Reply-To: <46D858A9.4080506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007 14:06:33 -0400 Jeff Garzik wrote:

> Robert P. J. Day wrote:
> > On Fri, 31 Aug 2007, Randy Dunlap wrote:
> > 
> >> On Thu, 19 Jul 2007 23:05:57 +0100 Simon Arlott wrote:
> >>
> >>> On 19/07/07 17:19, Robert P. J. Day wrote:
> >>>> On Thu, 19 Jul 2007, Randy Dunlap wrote:
> >>>>> I think that Stefan means a patch to the kconfig source code,
> >>>>> not the the Kconfig files.  Good luck.  I'd still like to see it.
> >>>> yes, i understand what he wanted now.  as a first step (that
> >>>> theoretically shouldn't change any behaviour), i'd patch the Kconfig
> >>>> structure to add a new attribute ("maturity") which would be allowed
> >>>> to be set to *exactly one* of a pre-defined set of values (say,
> >>>> OBSOLETE, DEPRECATED, EXPERIMENTAL, and STILLBLEEDING).  and that's
> >>>> it, nothing more.
> >>>>
> >>>> don't try to do anything with any of that just yet, just add the
> >>>> infrastructure to support the (optional) association of a maturity
> >>>> level with a config option.  that's step one.
> >>> What about something like this? I'm not sure if the addition to sym_init
> >>> is desirable... I also had to prefix _ to the name for now otherwise it
> >>> conflicts badly with the current symbols. It probably should stop
> >>> "depends on _BROKEN" etc. too.
> > 
> > i'm sure i'm going to get shouted down here, but i really disagree
> > with "BROKEN" being considered a "maturity level".  IMHO, things like
> > EXPERIMENTAL, DEPRECATED and OBSOLETE represent maturity levels, for
> > what i think are obvious reasons.
> > 
> > something like BROKEN, though, has *nothing* to do with maturity.  a
> > feature can be any of those maturity levels, and simultaneously be
> > BROKEN.  i consider BROKEN to be what i call a "status", and different
> > status levels might be the default of normal, or KIND_OF_FLAKY or
> > TOTALLY_BORKED -- that's where BROKEN would fit in.
> 
> BROKEN is definitely a maturity level.  A more accurate description 
> would be BITROTTING perhaps.  The code in question has passed through 
> bleeding -> experimental -> stable, and come out the other side.
> 
> In contrast, OBSOLETE and DEPRECATED reflect high-level status not code 
> quality/maturity.

What I like about the patch is that it associates some kconfig symbol
with prompt strings, so that we don't have to edit "(EXPERIMENTAL)"
all the darn time (e.g.).

I'd be quite happy with calling it "status" rather than "maturity",
and with being able to use multiple of the status tags at one time,
such as

	config FOO
	depends on BAR
	status OBSOLETE BROKEN


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
