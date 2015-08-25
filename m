From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 16:33:06 -0700
Message-ID: <55DCFB32.707@cumulusnetworks.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	linux@roeck-us.net, jiri@resnulli.us, sfeldma@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36149 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbbHYXdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:33:09 -0400
Received: by pacgr6 with SMTP id gr6so5749303pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 16:33:08 -0700 (PDT)
In-Reply-To: <20150825232021.GA8482@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 4:20 PM, Alexei Starovoitov wrote:
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
>>    net: add IFF_L2_ONLY flag
>>    net: ipv4: Skip in_dev initialization for IFF_L2_ONLY interfaces
>>    net: ipv6: Skip in6_dev initialization for IFF_L2_ONLY interfaces
>
> interesting idea! Do you know how kernel/iproute2 will react to lack of in_dev?
> No crashes I'm assuming, but what kind of errors are thrown?
> imo great first step to have lightweight netdevs. +1 for 'net_port' in the future.
>

I was looking a lightweight netdevice a couple of months ago -- 
bypassing procfs, sysfs and reducing the overall size of the net_device 
struct (which needs to go on a diet). In my POC (which is not ready for 
posting) I am using a link attribute (IFLA_LWT_NETDEV) as the trigger to 
bypass devinet_sysctl_register for example.

In your case you are proposing an interface flag. Is the intention to 
allow a run time change?

David
