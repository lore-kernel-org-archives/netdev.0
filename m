From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] d80211 LED handling
Date: Fri, 18 Aug 2006 08:59:28 +0200
Message-ID: <1155884368.3425.2.camel@ux156>
References: <44DC3809.10705@sipsolutions.net>
	 <20060817173030.6510e96d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:13546 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750742AbWHRG7E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 02:59:04 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060817173030.6510e96d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-17 at 17:30 +0200, Jiri Benc wrote:

> How is the driver supposed to add its led handlers?

The driver just adds an LED device. And then we only need to set the
default trigger correctly.

> Using generic led triggers is probably interesting for cases when system
> has some separate led. It won't help drivers which need to handle leds
> on the card itself. In the former case you may want all of wireless
> cards in the system to be connected to one led. I don't see how this is
> easily possible with this patch.

No, that's not possible at all. But we could have a generic
'd80211-all-cards' trigger I suppose.

>  In the latter case, you want to call
> callback provided by the driver and not to use generic led triggers at
> all.

Why not use the generic trigger anyway? With the right default...

> > [...]
> > +config D80211_LEDS
> > +	bool "Enable LED triggers"
> > +	select LEDS_TRIGGERS
> 
> Is it really necessary to have this as a configurable option?

Probably not.

> > [...]
> > +	name = (char*) local->rx_led+1;
> 
> This doesn't seem correct.

Hm, yeah, it probably needs to be (char*) (local->rx_led+1).

> > +	snprintf(name, IFNAMSIZ + 2, "%srx", local->mdev->name);
> 
> Name of interface may change at any time. Using it for fixed identifier
> is not a good idea. In addition, nothing prevents you from ending up
> with two different led triggers with the same name:
> 
> 1. modprobe card1
> 2. ieee80211_led_init(card1)	<- card1 is "wmaster0"
> 3. ip link set wmaster0 name mysupercard
> 4. modprobe card2
> 5. ieee80211_led_init(card2)	<- card2 is "wmaster0"

Good point. I guess we'll want to have the wiphy in there instead.

johannes
