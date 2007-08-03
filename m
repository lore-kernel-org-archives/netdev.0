From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 3 Aug 2007 19:26:45 +0900
Message-ID: <20070803102645.GO13674@htj.dyndns.org>
References: <20070802224206.GB5181@ifup.org> <20070803095857.5fb3f368@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brandon Philips <brandon@ifup.org>, netdev@vger.kernel.org,
	teheo@suse.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:39088 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758793AbXHCK0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 06:26:50 -0400
Received: by rv-out-0910.google.com with SMTP id k20so642928rvb
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 03:26:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070803095857.5fb3f368@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 09:58:57AM +0100, Stephen Hemminger wrote:
> On Thu, 2 Aug 2007 15:42:06 -0700
> Brandon Philips <brandon@ifup.org> wrote:
> 
> > This patch set adds support for devres in the net core and converts the
> > e100 and e1000 drivers to devres.  Devres is a simple resource manager
> > for device drivers, see Documentation/driver-model/devres.txt for more
> > information.
> > 
> > The use of devres will remain optional for drivers with this patch set.
> > Drivers can be converted when it makes sense.
> 
> Just because devres exists is not sufficient motivation to change.
> 
> It seems that devres was a band-aid rather than fixing storage drivers
> to have proper DMA lifetimes.

I don't really get what you mean by "having proper DMA lifetimes" but
please don't write devres off too fast.  devres doesn't solve any
problem that you can't fix without it but it does make the 'solving'
much easier.

IMHO, libata drivers generally have been well maintained and reviewed
but I could still find quite a few bugs (resource leaks or
occasionally double free) in init failure and removal paths.  Init
failure paths are especially prone to bugs because they don't get
excercised often.  It's just very easy to make a mistake and fail to
notice and low level drivers don't always get sufficient amount of
review or testing.

Skimming through drivers... via-rhine doesn't disable PCI device on
init failure path but does so on removal.  sky2 doesn't free
consistent memory if sky2_init() fails.  acenic calls iounmap() with
NULL parameter which I'm not sure whether it's safe or not.  natsemi
doesn't disable PCI device on failure or removal.

Devres makes low level drivers simpler, easier to get right and
maintain.  Writing new drivers becomes easier too.  So, why not?

> Network devices seem to work fine thanks, and the resource requirements
> are different. If ain't broke, don't fix it.

Care to enlighten me on how the resource requirments are different
from ATA drivers?

Thanks.

-- 
tejun
