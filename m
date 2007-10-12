From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 18:03:52 -0700 (PDT)
Message-ID: <20071011.180352.71088951.davem@davemloft.net>
References: <20071011.174026.26976971.davem@davemloft.net>
	<20071011175059.7b35c9a1@freepuppy.rosehill>
	<20071011.180031.41631586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753599AbXJLBEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:04:04 -0400
In-Reply-To: <20071011.180031.41631586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Oct 2007 18:00:31 -0700 (PDT)

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 11 Oct 2007 17:50:59 -0700
> 
> > On Thu, 11 Oct 2007 17:40:26 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > > Date: Thu, 11 Oct 2007 17:31:49 -0700
> > > 
> > > > You don't need to re-read the status register and process the PHY irq's inside loop.
> > > > Try this:
> > > 
> > > Are you sure?  What if a PHY interrupt comes in during the loop?
> > 
> > The interrupt is level triggered, and will rearm.
> 
> Fair enough.

Actually, your change isn't right for another reason.

You missed the necessary budget reducing logic that I used
in the original changes.  You need to adjust work_limit
like this:

		work_done += sky2_status_intr(hw, work_limit - work_done);

Otherwise if you just pass plain "work_limit", and we do loop, the
driver uses more quota than it really should.

And I've made that above correction to your patch in my tree.
