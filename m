From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Sun, 29 Jan 2017 11:02:53 -0700
Message-ID: <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:38788 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdA2SFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 13:05:46 -0500
Received: by mail-it0-f42.google.com with SMTP id c7so88085073itd.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 10:05:41 -0800 (PST)
In-Reply-To: <588D3EB9.1070107@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/28/17 6:00 PM, Roopa Prabhu wrote:
>> 4. Route Appends
>>    - IPv6 allows nexthops to be appended to an existing route. In this
>>      case one notification is sent per nexthop added
> 
> thanks for listing all of these...I think you mentioned this case to me..
> but I don't remember now why this notification is
> sent per nexthop added. This is an update to an existing multipath route.
> so seems like the notification should be a RTM_NEWROUTE with the full RTA_MULTIPATH route
> (similar to route add)

It could be; it's a question of what should userspace get -- the full route or the change? Append to me suggests the latter - userspace is told what changed. It is simpler kernel code wise to send the full new route. The append changes were done after our conversation. ;-)

> 
> Same holds for replace, I know the code might be tricky here...but the route replace
> is also an update to an existing multipath route and hence should be a RTM_NEWROUTE
> with the full multipath route (RTA_MULTIPATH) that changed (from userspace semantics POV)

It is. The only change on a replace is the encoding of all routes in RTA_MULTIPATH which is the point of this patch set. On successful replace, only 1 notification is sent with the full route.

> 
> I don't have a better solution, but with the above still being different, wondering
> if its worth the risk changing the api for just a few notifications.

Data centers are moving to L3, and multipath is a big part of that. Anyone who looks at ip -6 route enough knows it gets painful mentally pulling the individual routes into a single one. In addition, using RTA_MULTIPATH is more efficient at scale.

Furthermore, I have a follow on patch set that returns the route matched on an ip route get lookup. Returning the full multipath route is an important part to understanding the full context of the route to an address.
