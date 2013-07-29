From: William Manley <william.manley@youview.com>
Subject: Re: [PATCH 1/2] net: igmp: Reduce Unsolicited report interval to
 1s when using IGMPv3
Date: Mon, 29 Jul 2013 15:39:04 +0100
Message-ID: <51F67E88.6030006@youview.com>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374754445-5608-1-git-send-email-william.manley@youview.com> <20130726163239.GE3890@order.stressinduktion.org> <20130726163913.GG3890@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <bcrl@kvack.org>, <luky-37@hotmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <bhutchings@solarflare.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:44055
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753765Ab3G2Oji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 10:39:38 -0400
In-Reply-To: <20130726163913.GG3890@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/07/13 17:39, Hannes Frederic Sowa wrote:
> On Fri, Jul 26, 2013 at 06:32:39PM +0200, Hannes Frederic Sowa wrote:
>> On Thu, Jul 25, 2013 at 01:14:04PM +0100, William Manley wrote:
>>> If an IGMP join packet is lost you will not receive data sent to the
>>> multicast group so if no data arrives from that multicast group in a
>>> period of time after the IGMP join a second IGMP join will be sent.  The
>>> delay between joins is the "IGMP Unsolicited Report Interval".
>>>
>>> Previously this value was hard coded to be chosen randomly between 0-10s.
>>> This can be too long for some use-cases, such as IPTV as it can cause
>>> channel change to be slow in the presence of packet loss.
>>>
>>> The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
>>> IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
>>> later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
>>> unaffected.
>>>
>>> Tested with Wireshark and a simple program to join a (non-existent)
>>> multicast group.  The distribution of timings for the second join differ
>>> based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
>>>
>>> [...]
>>>
>>
>> [...]
>>
>> Otherwise I am fine with it.
>
> Also, could you have a look at IPv6, too? We currently use a hardcoded
> IGMP6_UNSOLICITED_IVAL = 10*HZ there.

I'll have a look, but I have to admit my ignorance on how multicast 
works with IPv6 and I may have difficulty setting up a test environment.

It seems that IGMP has been replaced with "Multicast Listener Discovery" 
on top of ICMPv6 and much like IGMP there is more than one version:

1. RFC2710 - MLD - Unsolicited Report Interval = 10s
2. RFC3810 - MLDv2 - Unsolicited Report Interval = 1s

There also seems to be a /proc/sys/net/ipv6/conf/all/force_mld_version. 
  Ok, so maybe it's not so difficult.  I'll see if I can come up with 
some additional patches but I'd prefer to keep them separate from the 
IPv4 ones which I hope are now good-to-go.

Thanks

Will
