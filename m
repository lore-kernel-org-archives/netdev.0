From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Tue, 14 Nov 2006 16:53:26 +0100
Message-ID: <200611141653.26355.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org> <20061114142959.GA17486@keitarou> <1163515224.2762.22.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Paul TBBle Hampson <Paul.Hampson@pobox.com>,
	netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59878
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S933443AbWKNPzI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 10:55:08 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163515224.2762.22.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 November 2006 15:40, Johannes Berg wrote:
> On Wed, 2006-11-15 at 01:29 +1100, Paul TBBle Hampson wrote:
> 
> > Just to summarise results so far:
> > 
> > (Current version)
> > bcm43xx-d80211 w/v3 firmware and TKIP: Garbled broadcast RX
> > bcm43xx-d80211 w/v4 firmware and TKIP: Garbled broadcast RX
> > bcm43xx-d80211 w/v4 firmware and WEP-104: Correct broadcast RX
> > 
> > (version from wireless-dev before October 23rd, unsure of exact date)
> > bcm43xx (softmac) w/v3 firmware and TKIP: Correct broadcast RX
> 
> The last item is interesting. The softmac version doesn't include any hw
> crypto so it never checks the 'decrypt attempted' bit in the RX header
> afaik, leaving all crypto to hw.
> 
> I postulated before that the problem is that the firmware sets the
> 'decrypt attempted' bit even if the key is none, hence the driver tells
> the d80211 stack that the frame was already decrypted (no decrypt error
> occurs because in reality the algorithm is 'none'.)
> 
> You could test this theory by clearing the 'decrypt attempted' bit
> unconditionally in the RX path before it is ever tested. Then, any
> wep/aes should no longer work properly with v4 firmware and
> bcm43xx-d80211, but tkip would. If my theory is correct.

yes, Johannes. The problem is that the decrypt attempted bit is even
set for key_none. When I force-disable this codepath, TKIP works
perfectly well.
I will do a patch for this. There are a few other minor bugs in the
crypto stuff, which I will fix, too. Key clearing is not handled 100%
correct, etc...

-- 
Greetings Michael.
