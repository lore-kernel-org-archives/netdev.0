From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] DSA: Convert msleep calls to usleep_range calls
Date: Thu, 3 Jan 2013 22:56:31 +0000
Message-ID: <1357253791.2685.48.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
	 <1357178098-4057-3-git-send-email-barry@grussling.com>
	 <1357244056.2685.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <CABLseQ6h8+Vu+eMwhTwC44vFArL107bLrwY-sipgR89RxWbSBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Barry Grussling <barry@grussling.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28480 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab3ACW4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 17:56:34 -0500
In-Reply-To: <CABLseQ6h8+Vu+eMwhTwC44vFArL107bLrwY-sipgR89RxWbSBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 14:33 -0800, Barry Grussling wrote:
> On Thu, Jan 3, 2013 at 12:14 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > I seriously doubt that it is worth the trouble to save wake-ups during
> > the occasional hardware reset.  And using usleep_range() 1000 times is
> > weird.  If the sleep duration can vary then the right thing to do is
> > probably to calculate a deadline first (jiffies + HZ) and then sleep
> > repeatedly until the deadline is in the past.  This also accounts for
> > the fact that HZ may be < 1000...
> 
> I don't think the idea here is variable sleep time.  Its more just
> giving hardware a little
> bit of time to catch up with firmware.  I don't really care about
> variable sleep times,
> but checkpatch.pl says msleep of less than 20 ms is bad and may result in sleep
> times of up to 20 ms for requests of shorter durations.

Still true for usleep_range() on hardware that doesn't have an hrtimer.

> Should I use udelay instead?  What is the recommended method for sleeping 1 ms?

This driver doesn't want to wait 1 ms, it wants to wait for up to 1
second and poll periodically.  Think about the whole loop, not just that
one function call.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
