From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Add wireless statics to bcm43xx-d80211
Date: Wed, 23 Aug 2006 09:54:04 +0200
Message-ID: <1156319644.3629.25.camel@ux156>
References: <44E07AA4.8040309@lwfinger.net>
	 <20060822160957.61a4e9ba@griffin.suse.cz>  <44EB7403.10705@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:13536 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751451AbWHWHxv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:53:51 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44EB7403.10705@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 16:15 -0500, Larry Finger wrote:
> >> +	int maxssi;
> > 
> > Why is maxssi here? Can it really change between received frames?
> 
> No it cannot change between frames; however, the max value can be very different for different 
> drivers using d80211. On the bcm43xx, it is 60; whereas 100 seems to be a better value for the 
> rt2x00 chips. Adding it here seemed like a good way to handle this situation. Do you suggest 
> something else?

I think the question was intended to be: "why is it in
ieee80211_rx_status and not in struct ieee80211_hw?"

> Again to pass the differing values for different drivers.

Ditto here. Just stick it into struct ieee80211_hw instead.

> > I would suggest using -110 dBm as a floor (to be compatible with RCPI
> > definition, see mail from Simon Barber describing it). Or is there any
> > particular reason for -104 dBm?
> 
> It is the value previously used in the softmac version of bcm43xx. A value of -110 would obviously 
> be better.

Who maintains the softmac version now? :P
I'd suggest to just change it there too for consistency.

johannes
