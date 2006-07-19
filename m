From: Dan Williams <dcbw@redhat.com>
Subject: Re: Wireless statistics for bcm43xx-d80211
Date: Wed, 19 Jul 2006 09:56:19 -0400
Message-ID: <1153317379.2537.2.camel@localhost.localdomain>
References: <44BDB400.40408@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50617 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964821AbWGSNzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 09:55:22 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44BDB400.40408@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-18 at 23:24 -0500, Larry Finger wrote:
> I have gotten most things working to produce wireless statistics through /proc/net/wireless for
> bcm43xx-d80211; however, I have one problem that I have not yet been able to solve. When I do a 'cat
> /proc/net/wireless', the following is printed:
> 
> Inter-| sta-|   Quality        |   Discarded packets               | Missed | WE
>   face | tus | link level noise |  nwid  crypt   frag  retry   misc | beacon | 20
> wmaster0: 0000  100.    0.    0.       0      0      0      0      0        0
>   wlan1: 0000  100.  -26.  -67.       0      0      0      0      0        0
> 
> Based on the numbers obtained using bcm43xx-softmac for my interface, the numbers for level and 
> noise for wlan1 are what I expected (in dBm). The link value has not yet been finished. The main 
> problem is that the wireless kicker applet for KDE, which I use for a display, is only looking at 
> the first line, and never sees the wlan1 data - only the wmaster0 results.
> 
> Is there some way to detect that the master interface is being interrogated, and return data for the
> attached STA instead?

Actually, now that I think about it, why are _any_ applets
screen-scraping /proc/net/wireless anymore?  If they profess to be a
wireless applet, yet screenscrape /proc/net/wireless, that's suspect
right there.  The ioctls for status are quite well-defined and haven't
changed in a very long time (ie, SIOCGIWRANGE).

On the flip side, /proc/net/wireless has been supported since the dawn
of time (ok, not really) and is the textual interface for reporting
wireless statistic, but maybe that shouldn't be the case anymore.

Dan


