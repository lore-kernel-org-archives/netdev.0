From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: proposal for new wireless configuration API
Date: Wed, 16 Aug 2006 09:26:40 +0200
Message-ID: <1155713201.3600.20.camel@ux156>
References: <1155655728.17742.30.camel@ux156>
	 <43e72e890608150914v3b831c18sea283aa26528553b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:10390 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750970AbWHPH0Q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 03:26:16 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890608150914v3b831c18sea283aa26528553b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 12:14 -0400, Luis R. Rodriguez wrote:

> Basically redo WE completely from scratch using netlink.

Not quite, I hope! As Dan mentioned, for example all the key management
stuff ought to be consolidated. Same for some other things.

> For per packet this makes sense, for modification of all packets I
> think configfs would be more suitable. Then again this is just an
> addition, I'm not disagreeing here with the approach. The same goes
> for several common wireless settings -- we could also have a configfs
> directory for each device which would allow manual read/writing for
> setting/getting certain values; mind you that congifs does allow for
> setting/getting multiple values at the same time, for those of you who
> have wondered. This could just could easily go in as a wrapper for
> configfs->new NL API.

Yeah, that might not even be undesirable. But we also need per-packet
controls, and a bunch of them. The current situation with a special
header in front of a packet injected into the management interface isn't
too great.

I'm not sure what kind of generic packet sending parameters we have.
Bitrate obviously, and all the other possible attributes...

> >    NL80211_ATTR_IFINDEX: index of interface to use

This was just meant to be the ifindex of the eth0 or whatever device.

> >    (NL80211_ATTR_PHYIDX: (later) index of wiphy to configure)
> 
> Do you mean to have a wireless device have its own device index,
> separate from the netdevice index? Can you elaborate a bit on this?

Well, the d80211 stack gives each driver backend phyN
in /sys/class/ieee80211/. If we ever want to get rid of the wmasterN
interface, we probably want to allow configuring without an ifindex
because the physical device might not have any network devices attached
at that time. I'm not exactly sure if it really makes sense to configure
the device then, but hey.

> With WE we were restricted to the number of attributes possibly
> changed by the number of ioctls and later by sub-ioctl hack
> restrictions. What restrictions are we to face with this? 

We can have tons of attributes, it's a 16-bit field. I think that should
be sufficient :)

> Do we want
> to map each attribute directly to the respective WE ioctl number to
> make it easy to do backward compatibility?

No, because that would mean having very large attribute numbers
up-front, and due to the way genetlink works there is memory allocated
for each possible attribute. Hence, attribute numbers should be
allocated in an increasing fashion starting from 1, and not be sparse.

johannes
