From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Wed, 12 Dec 2012 19:49:26 +0100
Message-ID: <20121212184925.GD3060@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
 <20121212081500.24085752@nehalam.linuxnetplumber.net>
 <20121212170520.GA3060@minipsycho.orion>
 <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
 <20121212181017.GB3060@minipsycho.orion>
 <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
 <20121212182556.GC3060@minipsycho.orion>
 <20121212103632.2020efce@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47359 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab2LLSta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 13:49:30 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so710391eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 10:49:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121212103632.2020efce@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 12, 2012 at 07:36:32PM CET, shemminger@vyatta.com wrote:
>On Wed, 12 Dec 2012 19:25:56 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Wed, Dec 12, 2012 at 07:12:08PM CET, shemminger@vyatta.com wrote:
>> >On Wed, 12 Dec 2012 19:10:17 +0100
>> >Jiri Pirko <jiri@resnulli.us> wrote:
>> >
>> >> ># ip li show dev dummy0
>> >> >12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state DORMANT mode DORMANT   
>> >> 
>> >> if you mean this "NO-CARRIER"
>> >> it has no direct relation with netif_carrier_ok().
>> >
>> >It is the same value (IFF_RUNNING) that is visible from user space.
>> 
>> static inline bool netif_carrier_ok(const struct net_device *dev)
>> {
>> 	        return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
>> }
>> 
>> So netif_carrier[ok/on/off] are working with on __LINK_STATE_NOCARRIER
>> bit. Not with IFF_RUNNING flag.
>
>What is the code path that you are worried about netif_carrier_ok being set or clear?
>The interaction here is complex, and right now LINK_STATE_NOCARRIER is purely
>controlled by the driver, your patch changes that, but before acking I want
>to make sure why it is required.

This patchset would provide a possibility to set or clear the carrier
from userspace. For dummy device it would serve for direct emulation
of link fail.

Also for team deriver, that would serve for teamd (userspace part) to
set the carrier actually on or off (in case of LACP runner for example
this is required).
