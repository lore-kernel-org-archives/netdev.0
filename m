From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:23:57 -0700
Message-ID: <55DCF90D.6030703@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825162433.41c111d6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	linux@roeck-us.net, jiri@resnulli.us, sfeldma@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35328 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbHYX0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:26:24 -0400
Received: by pacdd16 with SMTP id dd16so138772119pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:26:24 -0700 (PDT)
In-Reply-To: <20150825162433.41c111d6@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/08/15 16:24, Stephen Hemminger wrote:
> On Tue, 25 Aug 2015 15:50:10 -0700
> Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
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
>>   net: dsa: Flag slave network devices with IFF_L2_ONLY
>>   net: dsa: bcm_sf2: Allow disabling tagging protocol
>>
>>  drivers/net/dsa/bcm_sf2.c | 16 +++++++++++++---
>>  include/uapi/linux/if.h   |  5 ++++-
>>  net/dsa/slave.c           |  1 +
>>  net/ipv4/devinet.c        |  3 +++
>>  net/ipv6/addrconf.c       |  4 ++++
>>  5 files changed, 25 insertions(+), 4 deletions(-)
>>
> 
> Can you bridge these?

You can add such an interface to the bridge, but I am still figuring out
how functional such a bridge is, because with my change to bcm_sf2,
there is no switch tag inserted, so I cannot differentiate a BPDU from
Port 0, 1 etc... probably of limited use. You could still configure
VLANs using bridge vlan filtering though, which was the main idea.
-- 
Florian
