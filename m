From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 07:49:17 -0800
Message-ID: <588F607D.2050600@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com> <588D3EB9.1070107@cumulusnetworks.com> <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com> <588E80DB.3070209@cumulusnetworks.com> <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com> <588EA2E8.2040302@cumulusnetworks.com> <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36561 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdA3Pto (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:49:44 -0500
Received: by mail-pg0-f54.google.com with SMTP id 3so43448699pgj.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 07:49:18 -0800 (PST)
In-Reply-To: <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/17, 6:57 PM, David Ahern wrote:
> On 1/29/17 7:20 PM, Roopa Prabhu wrote:
>>> 2. Delete - 1 notification for each hop for all combinations of delete commands
>> here I was trying to say, for people deleting the full multipath route, you should send a RTA_MULTIPATH.
> The only way to do that is to call inet6_rt_notify() *before* the route delete work has been done in fib6_del_route. Right now it is called at the end - after all sibling associations have been dropped, a time in which it can no longer fill in RTA_MULTIPATH.
>
> fib6_del_route function does not have any failure paths and is called with the write lock held, so moving the notification might be ok. But it also means ignoring all subsequent failures from fib6_del, again which might be ok since the only failure is ENOENT which can not happen if we are walking the sibling list.
>
>
>> For the odd case of ipv6 single nexthop delete, you can continue to send a single nexthop delete (like today ..without RTA_MULTIPATH)
>> because there is no other way to notify a single nexthop delete with a RTM_DELROUTE.
>>
>> The reason I say this is because: keeping future in mind, this will make things consistent for majority of people who will
>> start using RTA_MULTIPATH for both ipv4 and ipv6 for adds and deletes (requests/notifications and dumps) the same way.
>> single next hop delete will just be around because of fear of breaking existing applications.
> Single next hop delete will be around because IPv6 allows it -- and because IPv4 needs to support it.
>
understand single next hop delete for ipv6 will be around..and my only point was to leave it around but not optimize for that case.
I don't think we should support single nexthop delete in ipv4 (I have not seen a requirement for that)... ipv4 is good as it is right now.
the additional complexity is not needed.
