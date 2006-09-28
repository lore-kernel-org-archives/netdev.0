From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 17:13:20 +0200
Message-ID: <200609281713.21082.mb@bu3sch.de>
References: <200609271726.34305.mb@bu3sch.de> <200609281643.04631.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:19119
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751203AbWI1PNa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:13:30 -0400
To: Dan Williams <dcbw@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159455169.2642.30.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 September 2006 16:52, Dan Williams wrote:
> On Thu, 2006-09-28 at 16:43 +0200, Michael Buesch wrote:
> > On Thursday 28 September 2006 16:37, Dan Williams wrote:
> > > On Thu, 2006-09-28 at 16:27 +0200, Johannes Berg wrote:
> > > > On Thu, 2006-09-28 at 10:19 -0400, Dan Williams wrote:
> > > > 
> > > > > I'd buy that argument.  When the driver gets the deauth message,
> > > > > shouldn't it be sending an IWAP 00:00:00:00:00:00 wireless event to
> > > > > userspace?
> > > > 
> > > > I thought we did that since a long time now, didn't you actually develop
> > > > the initial patch?
> > > 
> > > Yes, I think I did.  My point here wasn't that the driver is _not_
> > > sending those messages (it almost certainly is), but what's _implied_ by
> > > those messages.  Namely that, if you're using a tool like wpa_supplicant
> > > and/or NM, when you get a deauth from the AP and send the IWAP event,
> > > all bets are off because the tool will likely override whatever the
> > > driver thinks its doing.
> > > 
> > > I'm somewhat ambiguous on just how much policy a driver should try to
> > > enforce.  I guess I'm OK with reassociation with the _same_ credentials.
> > > But what airo does with "auto_wep" is very nearly, if not completely,
> > > crossing the line [1].  The real question is, how much should drivers
> > > really do, and how much should they leave to userspace?
> > 
> > IMO a driver should implement absolutely _zero_ policy, as this
> > is the only way to get the same (default) policy for different
> > cards. A driver should _only_ provide generic events for
> > userspace tools to make decisions.
> > A "I got a deauth" event is really enough for userspace to
> > know what to do.
> 
> As a counterpoint, does every developer _really_ want to run
> wpa_supplicant just to use a WEP-encrypted connection where you may
> occasionally get kicked off?

I think that's the way we want to take. Even for unencrypted networks,
probably. We want as much as possible of the high level MAC
implementation in userspace. Remember the summit and Simon's talk?
It was a good talk and made a lot of sense.

This userspace implementation should probably renamed from wpa_supplicant
to wireless_supplicant or whatever.

-- 
Greetings Michael.
