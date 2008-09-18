From: Jouni Malinen <j@w1.fi>
Subject: Re: [GIT]: Networking (WEXT events and 64/32 compat)
Date: Thu, 18 Sep 2008 15:13:10 -0700
Message-ID: <20080918221309.GA22034@hostap.isc.org>
References: <20080908.204323.04156464.davem@davemloft.net> <20080909040525.GA26151@hostap.isc.org> <20080917191128.GA23239@hostap.isc.org> <20080917.131133.135282530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j@w1.fi, jouni.malinen@atheros.com, alex.williamson@hp.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hostap.isc.org ([149.20.54.63]:35404 "EHLO hostap.isc.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755018AbYIRWYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 18:24:45 -0400
Content-Disposition: inline
In-Reply-To: <20080917.131133.135282530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2008 at 01:11:33PM -0700, David Miller wrote:
> Moving to a new event with a strictly sized datastructure, instead of
> one that has variable sized members like pointers and crap which are
> impossible to compat layer'ify, is indeed my preference.
> 
> But in that case, we might as well make nl80211 usable instead.

Would you be fine with continuing to use IFLA_WIRELESS for this or
should we reserve a new identifier for the nl80211 case? I'm assuming
that the base mechanism would continue to remain as a broadcast
rtnetlink message and the main difference to WEXT is in defining all
events as data with fixed size fields instead of C structures.

IFLA_WIRELESS messages start with two fixed size fields (16-bit len
and cmd) which would allow us to reserve a new cmd value for nl80211
messaages and then we could even share the helper functions in
wireless/wext.c and just replace wireless_send_event() with a new
function that generates the new event type.

As a first porting step, wireless_send_event() could be extended to send
both messages so that we do not need to modify all drivers to use the
new mechanism in the beginning (and the old WEXT events would continue
to be available for anyone who uses 32/32-bit or 64/64-bit
kernel/userspace).

As far as userspace is concerned, I would assume apps would eventually
start moving to using the new events. As an example, wpa_supplicant has
support for using either WEXT or nl80211 (though, this is still using
WEXT for places that nl80211 does not support yet) and I would likely
leave the WEXT case as-is and modify nl80211 interface to use only the
new event messages.

-- 
Jouni Malinen                                            PGP id EFC895FA
