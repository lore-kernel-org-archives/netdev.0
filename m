From: "Frank Schneider" <twodipu@hotmail.com>
Subject: Re: Loop detected - calling function from different modules
Date: Thu, 31 Aug 2006 11:53:03 +0200
Message-ID: <BAY101-F33A13C37EC4876E17B74C0AB3F0@phx.gbl>
References: <1157008676.3065.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s21.bay0.hotmail.com ([65.54.246.221]:19979 "EHLO
	bay0-omc3-s21.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751238AbWHaJxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 05:53:07 -0400
In-Reply-To: <1157008676.3065.10.camel@ux156>
To: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dear Johannes,

To port ath_pci to wlan(d80211) module and make it “one” module – might be a 
possible solution. But you know, ath_pci has some dependency and some binary 
crap(HAL)
More over, I need only an signal (e.g. by calling a funciton) in the ath_pci 
module when a data frame is sending out from the card(as AP)
We know struct net_device has a member pointer to a method called
hard_start_xmit that initiates the transmission through the device.
Wlan module already assigned a function ("ieee80211_hardstart" ) to this 
pointer
hard_start_xmit. It uses dev_queue_xmit() to transmit outgoing data frame 
from
AP.
Is it possible to assign another function in different module, e.g.
ath_pci I need to call this function when transmit data frame, but in 
practice,
this function will not send any data frame, e.g. won’t use dev_queue_xmit.

Or is any other way to get an indication in ath_pci module that an outgoing 
data
frame is gonna send out?

Any suggestions to do that please ?

regards,
Frank



>From: Johannes Berg <johannes@sipsolutions.net>
>On Wed, 2006-08-30 at 22:58 +0200, Frank Schneider wrote:
>
> > and i need to do same in reverse way, i.e. call a function from wlan 
>module
> > that is implemented in ath_pci module.
>
>No, you don't. Period. Either wlan provides services to ath_pci, or they
>should be one module. Besides, why don't you port atheros drivers to
>d80211 instead? And how about showing code? :)
>
>johannes
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/

