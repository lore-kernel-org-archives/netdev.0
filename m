From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net: skge breakage on 2.6.24-rc1
Date: Wed, 7 Nov 2007 15:06:21 -0800
Message-ID: <20071107150621.f2da7f69.akpm@linux-foundation.org>
References: <20071107214621.GA8865@zakalwe.fi>
	<20071107215348.GB8865@zakalwe.fi>
	<200711072350.30645.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shdl@zakalwe.fi, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56106 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758012AbXKGXHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 18:07:04 -0500
In-Reply-To: <200711072350.30645.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 7 Nov 2007 23:50:30 +0100 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> On Wednesday, 7 of November 2007, Heikki Orsila wrote:
> > On Wed, Nov 07, 2007 at 11:46:21PM +0200, Heikki Orsila wrote:
> > > After some bisecting, I found that net skge driver broke on
> > > 
> > > commit 7fb7ac241162dc51ec0f7644d4a97b2855213c32


Thanks for doing the bisection.  It's a good idea to cc the author of the
offending patch after having done this.

> > > My network card is:
> > > 
> > > 0000:00:0e.0 Ethernet controller: 3Com Corporation 3c940 10/100/1000Base-T [Marvell] (rev 12)
> > > 
> > > Linux cheradenine 2.6.24-rc1-dirty #15 Wed Nov 7 23:39:28 EET 2007 x86_64 GNU/Linux
> > 
> > Sorry, forgot to say what the problem is. Doing
> > 
> > 	nc host port < /dev/zero
> > 
> > on a sending machine (not skge) to an skge machine that is receiving:
> > 
> > 	nc -l -p port >/dev/null
> > 
> > with ~60 MiB/s speed, causes the interface go malfunct. A slow 
> > transfer doesn't cause a problem.
> > 
> > Also, after some fiddling, I noticed that not changing the register 
> > write order on patch:
> > 
> > +       skge_write32(hw, RB_ADDR(q, RB_END), end);
> >         skge_write32(hw, RB_ADDR(q, RB_WP), start);
> >         skge_write32(hw, RB_ADDR(q, RB_RP), start);
> > -       skge_write32(hw, RB_ADDR(q, RB_END), end);
> > 
> > fixes the visible effect.. Possibly not the root cause of the problem, 
> > but changing the order back fixes networking here.
> 
> Please put all of the relevant information into the bugzilla entry at
> http://bugzilla.kernel.org/show_bug.cgi?id=9321

Please cc netdev@vger.kernel.org on networking-related discussions.
