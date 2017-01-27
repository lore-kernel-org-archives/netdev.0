From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with
 multipath routes
Date: Fri, 27 Jan 2017 09:36:49 -0700
Message-ID: <582674ce-ed9e-9c9d-d88c-a7bfe6691d89@cumulusnetworks.com>
References: <20170124.110616.2098461870069191491.davem@davemloft.net>
 <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
 <c78afc85-8d18-0f63-68b3-63925e5d8c81@cumulusnetworks.com>
 <20170126.130054.2221154789287701062.davem@davemloft.net>
 <f30ab203-47f9-e333-3552-bf5e2dbeaaf9@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35089 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755239AbdA0QhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:37:23 -0500
Received: by mail-pg0-f43.google.com with SMTP id 194so82428633pgd.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 08:36:52 -0800 (PST)
In-Reply-To: <f30ab203-47f9-e333-3552-bf5e2dbeaaf9@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/17 9:29 AM, Nicolas Dichtel wrote:
> Le 26/01/2017 à 19:00, David Miller a écrit :
>> From: David Ahern <dsa@cumulusnetworks.com>
> [snip]
>>> Quagga does not properly handle IPv6 multipath routes received from
>>> the kernel. I checked this with debian/jessie version and our
>>> version, and Donald reviewed the source. It is broken.
>>
>> If this is true, quagga is asbolutely not an argument for this "breaking"
>> something.  It doesn't break anything.
> Ok, my tests also shows that quagga is buggy.
> Let's change the way to advertise these routes.
> 
> It would be great to also use RTA_MULTIPATH when a route is deleted (like in
> your patch 1/2).

I have updated notifications to use RTA_MULTIPATH. Working on the multipath add/delete/replace permutations now and what the notification looks like. Add/replace is easy and the notifications use RTA_MULTIPATH. Notifications for the delete path are complicated given that a delete could remove only a subset of nexthops. Given that, we might have to settle for a notification for each nexthop delete.

> 
> Note that there is still a difference between ipv4 and ipv6: in ipv4 when a
> nexthop is added/updated/removed, the whole route must be deleted and added
> again. In IPv6, nexthop can be managed one by one.
> It means that in ipv4, the full route is always dumped, which is not the case in
> ipv6.
> 

Yes. I have been working on how to delete a nexthop within an IPv4 route. It is much more complicated given how the route is stored compared to IPv6.
