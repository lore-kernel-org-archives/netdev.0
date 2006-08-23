From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] Add wireless statics to bcm43xx-d80211
Date: Wed, 23 Aug 2006 12:01:05 +0200
Message-ID: <20060823120105.7a2f6f82@griffin.suse.cz>
References: <44E07AA4.8040309@lwfinger.net>
	<20060822160957.61a4e9ba@griffin.suse.cz>
	<44EB7403.10705@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:34279 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964796AbWHWKBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 06:01:09 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44EB7403.10705@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 16:15:47 -0500, Larry Finger wrote:
> No it cannot change between frames; however, the max value can be very different for different 
> drivers using d80211. On the bcm43xx, it is 60; whereas 100 seems to be a better value for the 
> rt2x00 chips. Adding it here seemed like a good way to handle this situation. Do you suggest 
> something else?

As Johannes already said, it should be in ieee80211_hw. 

> >> [...]
> >> --- a/net/d80211/ieee80211_i.h
> >> +++ b/net/d80211/ieee80211_i.h
> >> @@ -337,6 +337,9 @@ struct ieee80211_local {
> >>  	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
> >>  	int open_count;
> >>  	int monitors;
> >> +	int link_quality;
> >> +	int noise;
> >> +	struct iw_statistics wstats;
> > 
> > Why are these three variables in ieee80211_local? They are not used
> > anywhere.
> 
> You are right about the first two; however, wstats is used in the new
> routine ieee80211_get_wireless_stats.

Oh, get_wireless_stats returns struct iw_statistics, so it needs to be
allocated all the time. Grr, that's stupid...

Okay, wstats really needs to be in ieee80211_local then.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
