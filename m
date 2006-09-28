From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 10:37:17 -0400
Message-ID: <1159454237.2642.17.camel@localhost.localdomain>
References: <200609271726.34305.mb@bu3sch.de>
	 <200609271950.47430.mb@bu3sch.de> <451B4AF6.3090203@lwfinger.net>
	 <200609281455.53763.mb@bu3sch.de>
	 <1159453174.2642.8.camel@localhost.localdomain>
	 <1159453641.2648.20.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37778 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750720AbWI1Ogd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 10:36:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159453641.2648.20.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 16:27 +0200, Johannes Berg wrote:
> On Thu, 2006-09-28 at 10:19 -0400, Dan Williams wrote:
> 
> > I'd buy that argument.  When the driver gets the deauth message,
> > shouldn't it be sending an IWAP 00:00:00:00:00:00 wireless event to
> > userspace?
> 
> I thought we did that since a long time now, didn't you actually develop
> the initial patch?

Yes, I think I did.  My point here wasn't that the driver is _not_
sending those messages (it almost certainly is), but what's _implied_ by
those messages.  Namely that, if you're using a tool like wpa_supplicant
and/or NM, when you get a deauth from the AP and send the IWAP event,
all bets are off because the tool will likely override whatever the
driver thinks its doing.

I'm somewhat ambiguous on just how much policy a driver should try to
enforce.  I guess I'm OK with reassociation with the _same_ credentials.
But what airo does with "auto_wep" is very nearly, if not completely,
crossing the line [1].  The real question is, how much should drivers
really do, and how much should they leave to userspace?

Dan

[1] if the auth mode (open or shared-key) doesn't work, airo schedules a
timer and bumps the auth mode to the other one automatically, and tries
reassociation.


