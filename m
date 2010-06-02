From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 18:21:17 +0200
Message-ID: <1275495677.3915.16.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:47777 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412Ab0FBQVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:21:21 -0400
In-Reply-To: <m1ljaxxvcj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 09:17 -0700, Eric W. Biederman wrote:

> >> Ah, so the network devices aren't getting removed?
> >
> > Well the netdevs are gone, just the links aren't going away. the
> > mac80211_hwsim directory is gone too.
> >
> >> Do you have network namespaces enabled in your kernel or disabled?
> >
> > enabled
> >
> >> And this is 2.6.35-rc1, right?
> >
> > yes.
> >
> > Come to think of it, maybe somehow it ends up removing
> > mac80211_hwsim/hwsim0 before wlan0, and thus the link stays around? I
> > guess I could make it print messages about that somehow?
> 
> The wireless drivers are a little different, and come to think of it
> network namespace support has been added to the wireless drivers since
> last I looked closely. 

Yeah, I now need to go add tagged sysfs support to it too.

>  Do you know what creates/deletes these links?
> Is it the normal register_netdevice -> device_add path?

Yes, they aren't done specially.

> I definitely changed the symlink code a little making things network namespace
> aware so it is reasonable to assume that something in my changes affected the
> wireless drivers.

> I took a quick look and with my patches against 2.6.33 I'm not seeing this.

Hmm. I'm also not seeing it with veth, it would seem that ought to be
similar?

> I take a closer look at 2.6.35-rc1 and see if I can figure out what is
> going on.  It would definitely be wrong if hwsim0 is removed before
> wlan0.

I don't know if that's happening .. just guessing that it might cause
such a problem, and maybe some things are deferred somehow? Since netdev
destruction can be deferred, but the wifi sysfs destruction isn't. But
then that link there should cause the refcount to not go down until the
link goes away>?

johannes

