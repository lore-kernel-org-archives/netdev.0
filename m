From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Runtime power management for network interfaces
Date: Tue, 1 Aug 2006 08:53:12 -0700
Message-ID: <20060801085312.7b418961@localhost>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>
	<20060731091728.4d992cf1@dxpl.pdx.osdl.net>
	<200607311729.41890.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45293 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751221AbWHAPxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 11:53:20 -0400
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200607311729.41890.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Jul 2006 17:29:41 -0700
David Brownell <david-b@pacbell.net> wrote:

> On Monday 31 July 2006 9:17 am, Stephen Hemminger wrote:
> > On Tue, 25 Jul 2006 11:59:52 -0400 (EDT)
> > Alan Stern <stern@rowland.harvard.edu> wrote:
> > 
> > > During a Power Management session at the Ottawa Linux Symposium,
> > > it was generally agreed that network interface drivers ought to
> > > automatically suspend their devices (if possible) whenever:
> > > 
> > >     (1) The interface is ifconfig'ed down, or
> > > 
> > >     (2) No link is available.
> > 
> > This is hard because most of the power may be consumed by the PHY
> > interface and it needs to be alive to see link.
> 
> True only for #2, yes?  I think #1 could be adopted pretty widely, but
> no driver I've yet come across implements that policy.  I think maybe
> Don Becker didn't have power management on the brain nearly
> enough.  :)
> 
> 
> > > Has any progress been made in this direction?  If not, a natural
> > > approach would be to start with a reference implementation in one
> > > driver which could then be copied to other drivers.
> > > 
> > 
> > The problem is not generic, it really is specific to each device.
> 
> For #2, yes.  Much less so for #1; if the hardware has a low power
> mode, there's no point in being in any other mode when the interface
> is down.
> 
> This might actually be a good time to start rethinking power
> management for network interfaces.  Upcoming kernels (see the MM
> tree) have new class methods for suspend() and resume(), with the
> notion that they should be offloading tasks from drivers.  For
> network links, that would most naturally be netif_device_detach() on
> suspend, etc; if netdevices were to provide suspend() and resume()
> methods, those could be called via class suspend/resume as well as
> when they're configured down/up.  Just an idea of course ... but it
> might well be possible that some changes like that would be a nice
> incremental power savings on many systems, while simplifying some
> tasks that often confuse driver writers.

The tg3 and sky2 drivers both do power saving when not up.
It doesn't need special generic support. Just don't bring chip
up if the interface is config'd down.

> 
> > We have all the necessary infrastructure to do the right thing in
> > the network device driver, but in many cases we don't have the code
> > or the technical information to do proper power management.
> 
> I think that's more true for wakeup events than for PM in general.
> After all, quite a lot of network drivers do have suspend() methods
> that do something even if it's just going into PCI_D3, and resume()
> methods that are fully capable of re-initializing from power-off.
> 
> - Dave
> 
