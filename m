From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Fri, 04 Jun 2010 10:28:33 +0200
Message-ID: <1275640113.9953.8.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:53954 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab0FDI2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 04:28:39 -0400
In-Reply-To: <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-04 at 10:15 +0200, Kay Sievers wrote:
> On Fri, Jun 4, 2010 at 08:54, Johannes Berg <johannes@sipsolutions.net> wrote:
> > On Wed, 2010-06-02 at 17:53 -0700, Eric W. Biederman wrote:
> >
> >> Johannes this should fix your issue with mac80211_hwsim, where
> >> the device symlink were not destroyed when the driver was removed.
> >
> > It does, thank you.
> >
> > FWIW, I'm happy changing hwsim too, but I don't think I quite understand
> > what you're proposing in your other email so I'll leave it up to you
> > since you now know what is causing the problem :)
> 
> Assuming that hwsim is th parent of the network interface, it should
> us a "struct bus_type" not a "struct class" for the subsystem it
> assigns the devices to.

It's all virtual, so yeah, I guess it is the parent? It currently
creates a virtual struct device in the hwsim class and assigns that to
the netdev parent indirectly via the wiphy or something like that.

> Classes should not be used for anything completely simple, at best not
> be used at all, they are just too simple. We never know about future
> requirements, which usually all go wrong with the non-extendable class
> logic.
> 
> The difference in the code to switch from class to bus should be minimal.

Does that mean cfg80211 (net/wireless/) should also not use a struct
class? I'm not familiar with any of these details, mind helping me out?

johannes

