From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][NET][BRIDGE] br_if: oops in port_carrier_check
Date: Tue, 13 Feb 2007 11:55:29 -0800
Message-ID: <20070213115529.6ea7e7bd@freekitty>
References: <20070207140916.088b1073@oldman>
	<20070209074211.GA1631@ff.dom.local>
	<20070209095204.7f43a964@oldman>
	<20070212064446.GA1651@ff.dom.local>
	<20070212102848.GA4275@ff.dom.local>
	<20070212094738.0a8ae896@localhost.localdomain>
	<20070213062650.GA1614@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49849 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbXBMTze (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:55:34 -0500
In-Reply-To: <20070213062650.GA1614@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Feb 2007 07:26:51 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Mon, Feb 12, 2007 at 09:47:38AM -0800, Stephen Hemminger wrote:
> > On Mon, 12 Feb 2007 11:28:48 +0100
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > 
> > > Here is my patch proposal for testing.
> > > If it doesn't work - forget about it.
> > > (Prepared with 2.6.20-git6 but could
> > > be applied to 2.6.20 also.)
> > > 
> > > Jarek P.
> > > 
> > > 
> > > dev_hold/dev_put added to prevent dev kfree
> > > during port_carrier_check runnig, while dev
> > > and port are removed.
> > 
> > No, holding the reference just stops the kfree, it doesn't
> > stop the device from being removed from the port.
> 
> But I wrote above it is only to prevent the kfree.
> 
> >        p = dev->br_port;
> >        if (!p)
> >                goto done;
> >        br = p->br;
> 
> Then p is NULL here and we goto done.
> 
> Sorry, but the first version was wrong (incomplete).
> Below I attach a new proposal.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Yes, this looks correct.  If carrier_check is pending the ref count
gets cleared by cancel. If carrier work is waiting for rtnl, then
it cleans itself up.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
