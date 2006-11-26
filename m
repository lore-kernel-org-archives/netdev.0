From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 13:12:20 +0100
Message-ID: <200611261312.20442.mb@bu3sch.de>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net> <45691273.9090803@gentoo.org> <1164535408.21459.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37770
	"EHLO vs166246.vserver.de") by vger.kernel.org with ESMTP
	id S935352AbWKZMTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 07:19:06 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1164535408.21459.3.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 26 November 2006 11:03, Johannes Berg wrote:
> On Sat, 2006-11-25 at 23:05 -0500, Daniel Drake wrote:
> 
> > Surely disabling the queue actually makes sense, in order to avoid 
> > frames designated for the "current session" being transmitted on 
> > different channels during scanning?
> 
> The problem is that queue disabling isn't refcounted so that a scan that
> collides with bcm43xx having disabled the queue for calibration might
> re-enable the queue while bcm43xx is still calibrating.
> 
> Clearly, this doesn't fully fix the problem because softmac will try to
> transmit frames during the calibration. Hence, a proper fix would be to
> not remove the calls to netif_tx_disable but make them go through
> softmac (ieee80211_tx_disable) to make sure that softmac doesn't try to
> scan while the queues are disabled, which would fix the aforementioned
> problem of softmac enabling the queue while the driver needs it disabled
> for free.

Yeah, but I don't think it's worth fixing. ;)
Simply removing this tx_disable in softmac fixes a _big_ bug
and that must be applied. The bug of being able to scan while
calibrating is very minor and not worth to fix. Fixing this
will likely introduce other bugs. It's simply not worth it
anymore.

This tx_disable remove patch must be applied, because it fixes
actual locking issues in the driver(s). And I think it is responsible
for several mysterious bugs we have seen in the past. I cannot
prove that, but I am pretty sure.
It must also be pushed for inclusion in -stable.

-- 
Greetings Michael.
