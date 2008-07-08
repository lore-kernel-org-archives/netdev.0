From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 7 Jul 2008 17:10:25 -0700
Message-ID: <20080707171025.081e124f@infradead.org>
References: <20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
	<adafxqlxqi5.fsf@cisco.com>
	<20080707.155723.48071035.davem@davemloft.net>
	<adazlotwalk.fsf@cisco.com>
	<20080707164425.0af7087b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42527 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbYGHAKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 20:10:33 -0400
In-Reply-To: <20080707164425.0af7087b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jul 2008 16:44:25 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Mon, 07 Jul 2008 16:14:31 -0700
> Roland Dreier <rdreier@cisco.com> wrote:
> 
> >  > I doubt it uses the RTNL semaphore elsewhere to protect
> >  > against this path, which is the only protection these
> >  > calls currently have.
> > 
> > As far as I can tell from reading the code, the only places in cxgb3
> > that use t3_read_flash() are in the netdevice's open and ioctl
> > methods, and the ethtool get_drvinfo method.  So as far as I can
> > tell the current code is fine as long as rtnl is held across
> > get_drvinfo.
> > 
> >  > Please don't bring up scarecrows, this looks like simply
> >  > a bug which already exists.
> > 
> > I don't even know how to take this.  "Please don't review our
> > changes"?? "Please don't report bugs"??
> > 
> >  - R.
> 
> Long term, it would be good to move the driver name into device
> struct? Easier and could work for all those random other drivers :-)

well we can already get it from the object model ;)
Dave just preferred to get it from ethtool and only get it from object
model if ethtool didn't work out.. (which makes sense)

I can see the point almost of having a generic_ethtool_getdrv which
just fills the struct from the object model data ;)



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
