From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Fri, 10 May 2013 01:34:24 +0100
Message-ID: <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	 <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <ronye@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12620 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755483Ab3EJAed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 20:34:33 -0400
In-Reply-To: <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-10 at 02:17 +0300, Or Gerlitz wrote:
> On Thu, May 9, 2013 at 6:24 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> >
> > On Wed, 2013-05-08 at 16:45 +0300, Or Gerlitz wrote:
> > > Here's a suggestion for API and implementation that lets the admin to
> > > configure
> > > the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three
> > > states
> > >
> > > Auto -        the VF link state will reflect the PF link state
> > >
> > > Enable - VF link stat will be always up, traffic from VF to VF can
> > >        work even if PF link is down.
> >
> > It seems like it would be useful to implement these two options on the PF as well.
> 
> You mean that PF <--> VF communication on the same node can be made to
> work even when the physical link is down? this is a bit problematic to
> model/implement I think. Generally speaking it makes things easier to
> grasp if PF is considered to be the uplink of the eSwitch whos link is
> 1:1 as the physical link, but need to think that a bit more.

Yeah.  In some ways it could be better for a PF driver to create two net
devices, one which acts as a vswitch port and one which bypasses it (if
possible).  But then that's going to confuse people too.  I don't think
we can win...

> > Perhaps the default should also be specified?
> 
> mmm, not sure if we can require/enforce the same default for all drivers.

I know. :-/  But arbitrary differences between drivers are no fun for
sysadmins.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
