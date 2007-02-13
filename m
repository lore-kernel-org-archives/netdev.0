From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET][BRIDGE] br_if: oops in port_carrier_check
Date: Tue, 13 Feb 2007 12:35:53 -0800 (PST)
Message-ID: <20070213.123553.38710118.davem@davemloft.net>
References: <20070212094738.0a8ae896@localhost.localdomain>
	<20070213062650.GA1614@ff.dom.local>
	<20070213115529.6ea7e7bd@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pterjan@gmail.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbXBMUfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:35:55 -0500
In-Reply-To: <20070213115529.6ea7e7bd@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 13 Feb 2007 11:55:29 -0800

> On Tue, 13 Feb 2007 07:26:51 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > On Mon, Feb 12, 2007 at 09:47:38AM -0800, Stephen Hemminger wrote:
> > > On Mon, 12 Feb 2007 11:28:48 +0100
> > > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > > 
> > > > Here is my patch proposal for testing.
> > > > If it doesn't work - forget about it.
> > > > (Prepared with 2.6.20-git6 but could
> > > > be applied to 2.6.20 also.)
> > > > 
> > > > Jarek P.
> > > > 
> > > > 
> > > > dev_hold/dev_put added to prevent dev kfree
> > > > during port_carrier_check runnig, while dev
> > > > and port are removed.
> > > 
> > > No, holding the reference just stops the kfree, it doesn't
> > > stop the device from being removed from the port.
> > 
> > But I wrote above it is only to prevent the kfree.
> > 
> > >        p = dev->br_port;
> > >        if (!p)
> > >                goto done;
> > >        br = p->br;
> > 
> > Then p is NULL here and we goto done.
> > 
> > Sorry, but the first version was wrong (incomplete).
> > Below I attach a new proposal.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Yes, this looks correct.  If carrier_check is pending the ref count
> gets cleared by cancel. If carrier work is waiting for rtnl, then
> it cleans itself up.

I've applied this patch, thanks everyone.

Stephen, do we want this in -stable?
