From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:24:36 -0700
Message-ID: <55DCF934.8000906@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	linux@roeck-us.net, jiri@resnulli.us, sfeldma@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33053 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865AbbHYX1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:27:01 -0400
Received: by pacti10 with SMTP id ti10so65909795pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:27:01 -0700 (PDT)
In-Reply-To: <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/08/15 16:20, Alexei Starovoitov wrote:
> On Tue, Aug 25, 2015 at 03:50:10PM -0700, Florian Fainelli wrote:
>> Hi all,
>>
>> This patch series implements a L2 only interface concept which basically denies
>> any kind of IP address configuration on these interfaces, but still allows them
>> to be used as configuration end-points to keep using ethtool and friends.
>>
>> A cleaner approach might be to finally come up with the concept of net_port
>> which a net_device would be a superset of, but this still raises tons of
>> questions as to whether we should be modifying userland tools to be able to
>> configure/query these interfaces. During all the switch talks/discussions last
>> year, it seemed to me like th L2-only interface is closest we have to a
>> "network port".
>>
>> Comments, flames, flying tomatoes welcome!
>>
>> Florian Fainelli (5):
>>   net: add IFF_L2_ONLY flag
>>   net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
>>   net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
> 
> interesting idea! Do you know how kernel/iproute2 will react to lack of in_dev?

Surprisingly pretty good so far, have not found a way to make the kernel
crash ;)

> No crashes I'm assuming, but what kind of errors are thrown?

If you try to assign an IP address to such an interface, you get:

# ifconfig gphy 192.168.1.1
ifconfig: SIOCSIFADDR: No buffer space available

> imo great first step to have lightweight netdevs. +1 for 'net_port' in the future.

Thanks!
-- 
Florian
