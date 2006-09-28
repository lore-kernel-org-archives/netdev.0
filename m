From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 14:55:53 +0200
Message-ID: <200609281455.53763.mb@bu3sch.de>
References: <200609271726.34305.mb@bu3sch.de> <200609271950.47430.mb@bu3sch.de> <451B4AF6.3090203@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:17793
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161109AbWI1M4H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 08:56:07 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <451B4AF6.3090203@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 September 2006 06:09, Larry Finger wrote:
> Michael Buesch wrote:
> > On Wednesday 27 September 2006 18:18, Larry Finger wrote:
> >> Michael Buesch wrote:
> >>> This fixes some race conditions in the WirelessExtension
> >>> handling and association handling code.
> >>>
> >>> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> >>>
> >>> ---
> >> This patch doesn't apply.
> > 
> > Oh, linville merged stuff on the 25th. That's the day I updated
> > my tree to do this patch. But seems like I did it just before
> > the merge.
> > Who could suspect that linville merges something. :D
> > *me runs away*
> > 
> > Anyway. Here's an updated patch.
> 
> NACK this version. It applied correctly, but introduced a new problem. My device occasionally gets 
> deauthentication messages from my AP.Preciously, it would do a scan or two, and then reauthenticate. 
> After your patch was applied, it never stops scanning.

Oh, well... It's impossible to completely fix softmac race issues.
I am _not_ going to rewrite huge parts of softmac to get locking
working. If you want this to be fixed, please hack up a solution by
yourself. I'm really not going to do more work on softmac. This
has various reasons. 1) I cannot reproduce all these bugs I'm hunting
2) Time is spent better at d80211 or other projects.

But to debug the problem:
Why do you get deauth messages? Broken AP?
I'd say that it's _correct_ behaviour to stop working
after getting a deauth ;). wpa_supplicant is responsible to re-auth.
Why doesn't it re-auth? Or does it do and it just doesn't work as
expected?

-- 
Greetings Michael.
