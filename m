From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: softmac: semantics of SIOCSIWFREQ
Date: Mon, 17 Apr 2006 12:06:49 -0700
Message-ID: <20060417190649.GA28534@bougret.hpl.hp.com>
References: <1145190888.6560.22.camel@localhost> <20060417163759.GB28203@bougret.hpl.hp.com> <1145299691.4116.11.camel@localhost>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, softmac-dev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:38324 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751212AbWDQTGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 15:06:53 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1145299691.4116.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 08:48:10PM +0200, Johannes Berg wrote:
> On Mon, 2006-04-17 at 09:37 -0700, Jean Tourrilhes wrote:
> 
> > 	Usually no, but...
> > 	If you are in managed mode, SIOCSIWFREQ usually should return
> > an error, because it is not allowed.
> 
> Ok.
> 
> > 	If you are in ad-hoc mode, SIOCSIWFREQ is used if a IBSS needs
> > to be created. After scanning is done, if you did not find any
> > network, you will create your own, and you will use the frequency that
> > was set. You should never return an error.
> 
> Right. Well it should return an error if it is 'associated' in ad-hoc
> mode too, no?

	Nope, you want to store it for later reuse.
	Let suppose the following sequence :
		iwconfig eth0 mode ad-hoc essid another-ibss
		sleep(2)
		iwconfig eth0 freq 2.42G essid a-new-ibss
	You don't want the second call to fail.

> > 	The struct iw_scan_req has all the goodies you need to control
> > scanning.
> 
> Right, so that's just a matter of using a different call to say where to
> scan. Gotcha. IOW -- those people that want wardriving should use kismet
> or whatever and properly control the driver via the iw_scan_req.

	Definitely. I was just pointing out that scanning behaviour is
not dictated by current setting of the drivers (except when the
hardware does it, cf. Ornoco).

> > 	The IW_FREQ_FIXED is mostly use for SIOCGIWFREQ, when
> > getting. It tells you if the frequency was set by the user or
> > automatically picked as the result of scanning.
> 
> Ah, but in which case is it set by the user? And is that 'fixed' then?

	It's easier to explain with bitrate. If the user does not set
the bitrate, or set it to 'auto', it's never 'fixed'. If the user set
explicitely a bitrate, it's 'fixed'.
	For freq, it's simpler. In managed mode, it's never 'fixed',
because the card/driver choose the frequency. In master mode, it's
almost always 'fixed', because the user has to set the frequency. In
ad-hoc mode, it depend in the node creates or not the IBSS.

> > 	I don't think any driver/hardware has the ability to set the
> > frequency to auto, so IW_FREQ_FIXED is the default.
> 
> What would 'auto' be?

	Well, in auto, I would expect the node to look either at the
scan result and/or noise level on the various frequency to decide where
to create the IBSS (ad-hoc) or BSS (master).

> > 	It's because softmac only implements managed mode.
> 
> We might do some sort of ad-hoc client-only with Pete's patch, but we'll
> never do master or wds I think.
> 
> > 	I've heard the call, I'll try to find some time for that.
> 
> Oh I was more thinking that I myself could add it somewhere after all
> our discussion. If you do that, even better, but with the things we have
> discussed already I can definitely help out.
> 
> johannes

	Have fun...

	Jean


