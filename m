From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] ipmr/ip6mr: add Netlink notifications on
 cache reports
Date: Thu, 15 Jun 2017 14:33:49 +0300
Message-ID: <2d412677-d31a-7740-952c-b1b007bbf075@cumulusnetworks.com>
References: <20170613170822.16310-1-julien@arista.com>
 <891d876f-18fb-706b-c269-ec8892d2f6ff@cumulusnetworks.com>
 <7b133850-bbdc-594c-f7f3-62e9d4adf1f3@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Donald Sharp <sharpd@cumulusnetworks.com>
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34719 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbdFOLdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:33:52 -0400
Received: by mail-wr0-f180.google.com with SMTP id 77so17893442wrb.1
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 04:33:52 -0700 (PDT)
In-Reply-To: <7b133850-bbdc-594c-f7f3-62e9d4adf1f3@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/17 00:51, Julien Gomes wrote:
> Hi Nikolay,
> 
> On 06/14/2017 05:04 AM, Nikolay Aleksandrov wrote:
> 
>> This has been on our todo list and I'm definitely interested in the implementation.
>> A few things that need careful consideration from my POV. First are the security
>> implications - this sends rtnl multicast messages but the rtnl socket has
>> the NL_CFG_F_NONROOT_RECV flag thus allowing any user on the system to listen in.
>> This would allow them to see the full packets and all reports (granted they can see
>> the notifications even now), but the full packet is like giving them the opportunity
>> to tcpdump the PIM traffic.
> 
> I definitely see how this can be an issue.
> From what I see, this means that either the packet should be
> transmitted another way, or another Netlink family should be used.
> 
> NETLINK_ROUTE looks to be the logical family to choose though,
> but then I do not see a proper other way to handle this.

Right, currently me neither, unless it provides a bind callback when registering
the kernel socket.

> 
> However I may just not be looking into the right direction,
> maybe you currently have another approach in mind?

I haven't gotten around to make (or even try) them but I was thinking about 2 options
ending up with a similar result:

1) genetlink
 It also has the NONROOT_RECV flag, but it also allows for a callback - mcast_bind()
 which can be used to filter.

or

2) Providing a bind callback to the NETLINK_ROUTE socket.

I haven't checked in detail how feasible each option is. To me 2) seems like the
cleaner/proper way to do it but it requires extending the rtnetlink api.

It would be nice to get feedback and comments from more people on this.

> 
>> My second (more fixable and minor) concern is about the packet itself, how do you
>> know that the packet is all linear so you can directly copy it ?
> 
> Indeed, I overlooked this possibility in this version.
> I will improve that.
> 

Thanks!
