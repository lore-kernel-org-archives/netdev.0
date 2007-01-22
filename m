From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Can someone please try...
Date: Mon, 22 Jan 2007 22:00:19 +0100
Message-ID: <200701222200.19784.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <200701222106.24329.mb@bu3sch.de> <1169498676.4453.14.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:59881
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932515AbXAVVBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 16:01:47 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <1169498676.4453.14.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 January 2007 21:44, Pavel Roskin wrote:
> Hello, Michael!
> 
> On Mon, 2007-01-22 at 21:06 +0100, Michael Buesch wrote: 
> > It's obviously some stack/memory corruption. But I'm not
> > sure if this is a stackoverflow. I'd rather say no, it isn't.
> > 
> > Could probably be triggered by something like kfree()ing
> > a dangling pointer or something...
> 
> Yes.  That's what my patch was for ("Fix major memory corruption bug").
> It was pretty hard to catch because I would find the consequences rather
> than to the offending code.  I got lucky after I enabled some weird
> options, such as 64Gb support and highmem debugging.  Whether it played
> any role or not, the oops finally happened where the driver tried to
> erase memory pointed to by the stale phy->lo_control pointer.
> 
> Now the situation is following.
> 
> No more random crashes.  There is still a crash if I rmmod the driver
> while wlan0 is up, but it's a separate issue, and it's easy to avoid
> (unlike the interface going down).  I hope to look at it soon.

Did you apply that d80211 rmmod crash fix that Michael Wu posted
recently. I bet it will fix your issue.

> The driver connects to a 802.11b Linksys router just fine.  I can send
> and receive data.  The driver is fully functional.  128-bit WEP is
> supported.

Nice.

> There are periodic bursts of assertion failures.  Looking at the driver,
> I see three places where lna a.k.a. phy->lo_gain[0] is assigned the
> value of 32 (written as 0x20 in one place).  It's not surprising that it
> exceeds 7 in lo_measure_feedthrough().

I know about these and I am going to fix that, soon.
Ignore it for the time being, please.

> I think the assert() should be replaced with a FIXME, which would not
> annoy end users so much.

Well, no. It's kind of: Michael, go ahead and fix that crap!
So I'd like to keep it to get me to fix it. :D

> And while at that, it would be great to 
> replace phy->lo_gain with four fields with descriptive names.
> phy->lo_gain is never used as an array.  Alternatively, you could make
> it a structure within bcm43xx_phy.

Yeah, one step after the other. ;)
We didn't know the meanings of the values until recently. Of course
I am going to rename them.

> The problems with a MadWifi based AP turn out to be related to 802.11g.
> If the AP is configured for 802.11b only, everything is working.  If
> 802.11g is enabled, strange things are happening.  Judging by what's on
> the air, it looks like the driver loses the data frames is receives.
> wpa_supplicant connects instantly, but ARP and ping packets from AP to
> STA are lost.  The frames are even acknowledged, but not seen on the
> station side.  It takes from one to ten minutes util ping suddenly
> starts working.

Hm, is this 4318? It is known to loose lots of packets.

-- 
Greetings Michael.
