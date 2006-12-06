From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 6 Dec 2006 23:51:06 +0100
Message-ID: <200612062351.07016.mb@bu3sch.de>
References: <4576D778.mailLQC18T1PN@lwfinger.net> <200612062152.36475.mb@bu3sch.de> <20061206215101.GA24100@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:55740
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937761AbWLFWvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 17:51:21 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061206215101.GA24100@p15091797.pureserver.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 December 2006 22:51, Ulrich Kunitz wrote:
> On 06-12-06 21:52 Michael Buesch wrote:
> 
> > On Wednesday 06 December 2006 21:17, Ulrich Kunitz wrote:
> > > On 06-12-06 18:52 Michael Buesch wrote:
> > > 
> > > > All data in mac->associnfo is protected by mac->associnfo->mutex
> > > > and _not_ mac->lock.
> > > 
> > > Are you sure?
> > 
> > Yes I am.
> > 
> > > One can find for instance the following function in 
> > > ieee80211softmac_assoc.c:
> > 
> > This is not the first time we notice that locking
> > is completely broken in softmac. ;)
> 
> So the right thing would be to add another work function
> (*_start_reassoc_work) which sets the associating variable and
> calls then *_assoc_work? 

Ah, well. I think the right thing doesn't exist.
Even if you replace the lock by the mutex, it's still racy.
The whole lock design of softmac is broken and racy and we
can't simply fix that with a oneliner.

I'd say, John, apply the original patch as-is, as it does
more good than harm.

Basically, I just wanted to point out that this is not race-free.
But I think we can live with it.

-- 
Greetings Michael.
