From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 09:37:59 -0700
Message-ID: <20060417163759.GB28203@bougret.hpl.hp.com>
References: <1145190888.6560.22.camel@localhost>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:17835 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751151AbWDQQiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:38:01 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1145190888.6560.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 16, 2006 at 02:34:48PM +0200, Johannes Berg wrote:
> [breaking out to a new thread so discussion on this doesn't get too
> hidden, CC Jean since he designed this]
> 
> > - Is SIOCSIWFREQ allowed while associated?
> 
> No idea.

	Usually no, but...
	If you are in managed mode, SIOCSIWFREQ usually should return
an error, because it is not allowed.
	If you are in ad-hoc mode, SIOCSIWFREQ is used if a IBSS needs
to be created. After scanning is done, if you did not find any
network, you will create your own, and you will use the frequency that
was set. You should never return an error.
	If you are in Master mode... Well, this case is obvious ;-)

> > - If the flag IW_FREQ_FIXED is set, should all activitity
> >   including scanning only be allowed on this frequency? (Actually
> >   a better would even be to work with channel/frequency sets.
> >   These sets would make a lot of sense for parallel scanning
> >   whith more than one device.)
> 
> Yeah, but that's impossible to code on top of the current wext
> structures I'd say.

	The struct iw_scan_req has all the goodies you need to control
scanning.
	The IW_FREQ_FIXED is mostly use for SIOCGIWFREQ, when
getting. It tells you if the frequency was set by the user or
automatically picked as the result of scanning.
	I don't think any driver/hardware has the ability to set the
frequency to auto, so IW_FREQ_FIXED is the default.

> > - Is there any use of the control, if the frequency is not fixed?
> 
> Good question :)

	In managed mode, no.

> > SIOCSIWFREQ and SIOCGIWFREQ appear to be good candidates to be
> > included in the softmac. If I would have a rough idea, what the
> > semantics should be, I would even volunteer to implement it.
> 
> Yes, they definitely could/should be moved into softmac, but when
> writing softmac I had no real incentive to do it because I didn't want
> to dig up the info for all the above points :)

	It's because softmac only implements managed mode.

> I was thinking of adding all the 'what is this ioctl supposed to do'
> things we came up with to the softmac or netdev wiki. Would that be
> good/useful, or should we just put it into that driver writers guide?

	I've heard the call, I'll try to find some time for that.

> johannes

	Jean
