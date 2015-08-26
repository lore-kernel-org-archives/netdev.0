From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Wed, 26 Aug 2015 10:37:24 -0700
Message-ID: <55DDF954.1000903@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825.171248.291365392844717283.davem@davemloft.net> <A41B4B28-7D28-4BFB-AD4F-508C24AB82CA@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>, andrew@lunn.ch,
	Guenter Roeck <linux@roeck-us.net>, jiri@resnulli.us,
	sfeldma@gmail.com
To: Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36817 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbbHZRjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:39:53 -0400
Received: by pacgr6 with SMTP id gr6so15397187pac.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 10:39:52 -0700 (PDT)
In-Reply-To: <A41B4B28-7D28-4BFB-AD4F-508C24AB82CA@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/08/15 21:24, Marcel Holtmann wrote:
> Hi Dave,
> 
>>> This patch series implements a L2 only interface concept which
>>> basically denies any kind of IP address configuration on these
>>> interfaces, but still allows them to be used as configuration
>>> end-points to keep using ethtool and friends.
>>>
>>> A cleaner approach might be to finally come up with the concept of
>>> net_port which a net_device would be a superset of, but this still
>>> raises tons of questions as to whether we should be modifying
>>> userland tools to be able to configure/query these
>>> interfaces. During all the switch talks/discussions last year, it
>>> seemed to me like th L2-only interface is closest we have to a
>>> "network port".
>>>
>>> Comments, flames, flying tomatoes welcome!
>>
>> Interesting, indeed.
>>
>> Do you plan to extend this to defining a more minimal network device
>> sub-type as well?
>>
>> Then we can pass "net_device_common" or whatever around as a common
>> base type of actual net device "implementations".
>>
>> Or is you main goal just getting the L2-only semantic?
> 
> the other end of this could be also an IP only net_device where we do not have ethtool semantics.
> 
> We do have a need for a IPv6 only net_device when utilizing ARPHRD_6LOWPAN for 802.15.4 and Bluetooth LE. Skipping in_dev initialization there might be an interesting step towards that. Not sure how much entangled in_dev and in6_dev still are. If it works for IFF_L2_ONLY, it might work also in the other direction.

Just out of curiosity, is the aim for IPv6 only net_device to be denying
any kind of IPv4 configuration/tools, or is it for performance purposes?

The IFF_L2_ONLY flag would probably need to mean something like
(IFF_NO_IPV4 | IFF_NO_IPV6) such that you could decide which one of the
two IP stacks you want to use, or none.
-- 
Florian
