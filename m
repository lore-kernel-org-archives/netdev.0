From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 21:24:49 -0700
Message-ID: <A41B4B28-7D28-4BFB-AD4F-508C24AB82CA@holtmann.org>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825.171248.291365392844717283.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, Network Development <netdev@vger.kernel.org>,
	andrew@lunn.ch, Guenter Roeck <linux@roeck-us.net>,
	jiri@resnulli.us, sfeldma@gmail.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:38820 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbbHZEY6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 00:24:58 -0400
In-Reply-To: <20150825.171248.291365392844717283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>> This patch series implements a L2 only interface concept which
>> basically denies any kind of IP address configuration on these
>> interfaces, but still allows them to be used as configuration
>> end-points to keep using ethtool and friends.
>> 
>> A cleaner approach might be to finally come up with the concept of
>> net_port which a net_device would be a superset of, but this still
>> raises tons of questions as to whether we should be modifying
>> userland tools to be able to configure/query these
>> interfaces. During all the switch talks/discussions last year, it
>> seemed to me like th L2-only interface is closest we have to a
>> "network port".
>> 
>> Comments, flames, flying tomatoes welcome!
> 
> Interesting, indeed.
> 
> Do you plan to extend this to defining a more minimal network device
> sub-type as well?
> 
> Then we can pass "net_device_common" or whatever around as a common
> base type of actual net device "implementations".
> 
> Or is you main goal just getting the L2-only semantic?

the other end of this could be also an IP only net_device where we do not have ethtool semantics.

We do have a need for a IPv6 only net_device when utilizing ARPHRD_6LOWPAN for 802.15.4 and Bluetooth LE. Skipping in_dev initialization there might be an interesting step towards that. Not sure how much entangled in_dev and in6_dev still are. If it works for IFF_L2_ONLY, it might work also in the other direction.

Regards

Marcel
