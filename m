From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 3 Aug 2007 12:07:45 +0100
Message-ID: <20070803120745.2d89c221@oldman.hamilton.local>
References: <20070802224206.GB5181@ifup.org>
	<20070803095857.5fb3f368@oldman.hamilton.local>
	<20070803102645.GO13674@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brandon Philips <brandon@ifup.org>, netdev@vger.kernel.org,
	teheo@suse.de
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42747 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759473AbXHCLHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 07:07:30 -0400
In-Reply-To: <20070803102645.GO13674@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Aug 2007 19:26:45 +0900
Tejun Heo <htejun@gmail.com> wrote:

> On Fri, Aug 03, 2007 at 09:58:57AM +0100, Stephen Hemminger wrote:
> > On Thu, 2 Aug 2007 15:42:06 -0700
> > Brandon Philips <brandon@ifup.org> wrote:
> > 
> > > This patch set adds support for devres in the net core and converts the
> > > e100 and e1000 drivers to devres.  Devres is a simple resource manager
> > > for device drivers, see Documentation/driver-model/devres.txt for more
> > > information.
> > > 
> > > The use of devres will remain optional for drivers with this patch set.
> > > Drivers can be converted when it makes sense.
> > 
> > Just because devres exists is not sufficient motivation to change.
> > 
> > It seems that devres was a band-aid rather than fixing storage drivers
> > to have proper DMA lifetimes.
> 
> I don't really get what you mean by "having proper DMA lifetimes" but
> please don't write devres off too fast.  devres doesn't solve any
> problem that you can't fix without it but it does make the 'solving'
> much easier.
> 
> IMHO, libata drivers generally have been well maintained and reviewed
> but I could still find quite a few bugs (resource leaks or
> occasionally double free) in init failure and removal paths.  Init
> failure paths are especially prone to bugs because they don't get
> excercised often.  It's just very easy to make a mistake and fail to
> notice and low level drivers don't always get sufficient amount of
> review or testing.
> 
> Skimming through drivers... via-rhine doesn't disable PCI device on
> init failure path but does so on removal.  sky2 doesn't free
> consistent memory if sky2_init() fails.  acenic calls iounmap() with
> NULL parameter which I'm not sure whether it's safe or not.  natsemi
> doesn't disable PCI device on failure or removal.

Did you report these to the developers?

> Devres makes low level drivers simpler, easier to get right and
> maintain.  Writing new drivers becomes easier too.  So, why not?
> 
> > Network devices seem to work fine thanks, and the resource requirements
> > are different. If ain't broke, don't fix it.
> 
> Care to enlighten me on how the resource requirments are different
> from ATA drivers?

I was thinking of the hot remove (no mod ref counts) and lingering
/sys open issues.  ATA drivers use ref counts.

My take on devres is that it is similar to talloc() for device drivers.
Not a bad idea in itself, but the real advantage of hierarchical allocation
is that it makes exception handling easier if things are layered deeply.
