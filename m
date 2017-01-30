From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Sun, 29 Jan 2017 18:20:24 -0800
Message-ID: <588EA2E8.2040302@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com> <588D3EB9.1070107@cumulusnetworks.com> <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com> <588E80DB.3070209@cumulusnetworks.com> <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34878 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750900AbdA3CUu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 21:20:50 -0500
Received: by mail-pg0-f41.google.com with SMTP id 194so96851688pgd.2
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 18:20:26 -0800 (PST)
In-Reply-To: <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/17, 5:29 PM, David Ahern wrote:
[snip]
> Let's give an example for each case:
>
> 1. Add - full multipath route
>
> This route command:
> ip -6 ro add vrf red 2001:db8:200::/120 nexthop via 2001:db8:1::2 nexthop via 2001:db8:2::2
>
> generates this notification (ip -t mon ro):
>
> 2001:db8:200::/120 table red metric 1024
>         nexthop via 2001:db8:1::2  dev eth1 weight 1
>         nexthop via 2001:db8:2::2  dev eth2 weight 1
>

ack,
> 2. Delete - 1 notification for each hop for all combinations of delete commands

here I was trying to say, for people deleting the full multipath route, you should send a RTA_MULTIPATH.
For the odd case of ipv6 single nexthop delete, you can continue to send a single nexthop delete (like today ..without RTA_MULTIPATH)
because there is no other way to notify a single nexthop delete with a RTM_DELROUTE.

The reason I say this is because: keeping future in mind, this will make things consistent for majority of people who will
start using RTA_MULTIPATH for both ipv4 and ipv6 for adds and deletes (requests/notifications and dumps) the same way.
single next hop delete will just be around because of fear of breaking existing applications.

>
>
> 3. Replace -  full multipath route
>
> This route command (with the one from Add case already in place):
> ip -6 ro replace vrf red 2001:db8:200::/120 nexthop via 2001:db8:1::16 nexthop via 2001:db8:2::16
>
> generates a single notification:
>
> Replaced 2001:db8:200::/120 table red metric 1024
>         nexthop via 2001:db8:1::16  dev eth1 weight 1
>         nexthop via 2001:db8:2::16  dev eth2 weight 1

ack,
>
> 4. Append - 1 route after all hops are appended
>
> This append command (starting with the one installed from the Replace case):
> ip -6 ro append vrf red 2001:db8:200::/120 nexthop via 2001:db8:2::20 nexthop via 2001:db8:1::20
>
> generates a single notification:
>
> Append 2001:db8:200::/120 table red metric 1024
>         nexthop via 2001:db8:2::20  dev eth2 weight 1
>         nexthop via 2001:db8:1::20  dev eth1 weight 1
>         nexthop via 2001:db8:1::16  dev eth1 weight 1
>         nexthop via 2001:db8:2::16  dev eth2 weight 1
>
> (The Replaced and Append annotations are due to a local iproute2 patch; iproute2 does
> not currently distinguish NEWROUTE cases.)
>

ack,

thanks
