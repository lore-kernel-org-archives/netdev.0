From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Mon, 13 May 2013 00:48:22 +0300
Message-ID: <CAJZOPZ+fe7wx=3Xod-PoF-v5s+s+L0j1VjakWNdv97V_u_CQfA@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>
	<1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:65257 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab3ELVsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 17:48:23 -0400
Received: by mail-qa0-f45.google.com with SMTP id hu16so1109579qab.18
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 14:48:22 -0700 (PDT)
In-Reply-To: <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 10, 2013 at 3:34 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2013-05-10 at 02:17 +0300, Or Gerlitz wrote:
> > On Thu, May 9, 2013 at 6:24 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > >
> > > On Wed, 2013-05-08 at 16:45 +0300, Or Gerlitz wrote:
> > > > Here's a suggestion for API and implementation that lets the admin to
> > > > configure
> > > > the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three
> > > > states
> > > >
> > > > Auto -        the VF link state will reflect the PF link state
> > > >
> > > > Enable - VF link stat will be always up, traffic from VF to VF can
> > > >        work even if PF link is down.
> > >
> > > It seems like it would be useful to implement these two options on the PF as well.
> >
> > You mean that PF <--> VF communication on the same node can be made to
> > work even when the physical link is down? this is a bit problematic to
> > model/implement I think. Generally speaking it makes things easier to
> > grasp if PF is considered to be the uplink of the eSwitch whos link is
> > 1:1 as the physical link, but need to think that a bit more.
>
> Yeah.  In some ways it could be better for a PF driver to create two net
> devices, one which acts as a vswitch port and one which bypasses it (if possible).

That's interesting approach, any rough thoughts what you think it would by us?

> But then that's going to confuse people too.  I don't think we can win...
>
> > > Perhaps the default should also be specified?
> >
> > mmm, not sure if we can require/enforce the same default for all drivers.
>
> I know. :-/  But arbitrary differences between drivers are no fun for sysadmins.

yes, basically, on a production cloud environment, I would say that
before a vport (VF) interface
is configured, e.g ndo_set_vf_yyy is applied for it, we would want the
VF link to be down, but for non
production environments it could be problematic to have down/disabled
as the default... not sure, maybe
the default should be auto and for smart env they would set it to down
before the VF is probed on the VM?

Or.
