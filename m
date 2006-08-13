From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw: cleanups
Date: Sun, 13 Aug 2006 11:50:39 +0200
Message-ID: <20060813095039.GA9776@p15091797.pureserver.info>
References: <20060812170017.278D08E7782@zog.reactivated.net> <200608131124.34935.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:40650 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750869AbWHMJuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 05:50:40 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <200608131124.34935.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-13 11:24 Michael Buesch wrote:

> On Saturday 12 August 2006 19:00, Daniel Drake wrote:
> > --- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
> > +++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
> > @@ -127,11 +127,9 @@ out:
> >  
> >  void zd_mac_clear(struct zd_mac *mac)
> >  {
> > -	/* Aquire the lock. */
> > -	spin_lock(&mac->lock);
> > -	spin_unlock(&mac->lock);
> >  	zd_chip_clear(&mac->chip);
> > -	memset(mac, 0, sizeof(*mac));
> > +	ZD_ASSERT(!spin_is_locked(&mac->lock));
> 
> I think this assertion will always trigger on UP kernels
> with spinlock debugging disabled.

On UP the spin lock will be never locked, so the assert can never
fail. It's tested.

-- 
Uli Kunitz
