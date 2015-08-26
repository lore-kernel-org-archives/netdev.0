From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Wed, 26 Aug 2015 10:56:09 -0700
Message-ID: <BC7F5FFB-65E3-47A6-BB52-658DA32E1D48@holtmann.org>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825.171248.291365392844717283.davem@davemloft.net> <A41B4B28-7D28-4BFB-AD4F-508C24AB82CA@holtmann.org> <55DDF954.1000903@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, andrew@lunn.ch,
	Guenter Roeck <linux@roeck-us.net>,
	Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43221 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbbHZR4n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:56:43 -0400
In-Reply-To: <55DDF954.1000903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

>>>> This patch series implements a L2 only interface concept which
>>>> basically denies any kind of IP address configuration on these
>>>> interfaces, but still allows them to be used as configuration
>>>> end-points to keep using ethtool and friends.
>>>> 
>>>> A cleaner approach might be to finally come up with the concept of
>>>> net_port which a net_device would be a superset of, but this still
>>>> raises tons of questions as to whether we should be modifying
>>>> userland tools to be able to configure/query these
>>>> interfaces. During all the switch talks/discussions last year, it
>>>> seemed to me like th L2-only interface is closest we have to a
>>>> "network port".
>>>> 
>>>> Comments, flames, flying tomatoes welcome!
>>> 
>>> Interesting, indeed.
>>> 
>>> Do you plan to extend this to defining a more minimal network device
>>> sub-type as well?
>>> 
>>> Then we can pass "net_device_common" or whatever around as a common
>>> base type of actual net device "implementations".
>>> 
>>> Or is you main goal just getting the L2-only semantic?
>> 
>> the other end of this could be also an IP only net_device where we do not have ethtool semantics.
>> 
>> We do have a need for a IPv6 only net_device when utilizing ARPHRD_6LOWPAN for 802.15.4 and Bluetooth LE. Skipping in_dev initialization there might be an interesting step towards that. Not sure how much entangled in_dev and in6_dev still are. If it works for IFF_L2_ONLY, it might work also in the other direction.
> 
> Just out of curiosity, is the aim for IPv6 only net_device to be denying
> any kind of IPv4 configuration/tools, or is it for performance purposes?

when you have 6LoWPAN, then it would be actually good to forbid IPv4 configuration on these interface since they have no mapping whatsoever. Eventually it might allow us to decrease the size of the network stack for embedded sensor devices.

> The IFF_L2_ONLY flag would probably need to mean something like
> (IFF_NO_IPV4 | IFF_NO_IPV6) such that you could decide which one of the
> two IP stacks you want to use, or none.

I think IFF_NO_IPV4 and IFF_NO_IPV6 instead of IFF_L2_ONLY sounds like a good idea.

Regards

Marcel
