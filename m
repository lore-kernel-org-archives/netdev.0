From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 10:45:57 -0800
Message-ID: <588F89E5.9060503@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com> <588D3EB9.1070107@cumulusnetworks.com> <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com> <588E80DB.3070209@cumulusnetworks.com> <71e661bd-e26d-2629-06bb-888f6a09b06d@cumulusnetworks.com> <588EA2E8.2040302@cumulusnetworks.com> <5be4a78e-64b8-abc4-4015-6751a2bab12b@cumulusnetworks.com> <588F607D.2050600@cumulusnetworks.com> <d987faff-ced4-8791-8bdb-ba8a66aec6f5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35281 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbdA3Sqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 13:46:46 -0500
Received: by mail-pf0-f182.google.com with SMTP id f144so92246568pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 10:45:58 -0800 (PST)
In-Reply-To: <d987faff-ced4-8791-8bdb-ba8a66aec6f5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17, 8:12 AM, David Ahern wrote:
> On 1/30/17 8:49 AM, Roopa Prabhu wrote:
>>> Single next hop delete will be around because IPv6 allows it -- and because IPv4 needs to support it.
>>>
>> understand single next hop delete for ipv6 will be around..and my only point was to leave it around but not optimize for that case.
>> I don't think we should support single nexthop delete in ipv4 (I have not seen a requirement for that)... ipv4 is good as it is right now.
>> the additional complexity is not needed.
>>
> IPv4 has a known bug -- delete a virtual interface in a multihop route and the entire route is deleted, including the nexthops for other devices. This does not happen for IPv6.
>
> Simple example of that bug:
>
> ip li add dummy1 type dummy
> ip li add dummy2 type dummy
> ip addr add dev dummy1 10.11.1.1/28
> ip li set dummy1 up
> ip addr add dev dummy2 10.11.2.1/28
> ip li set dummy2 up
> ip ro add 1.1.1.0/24 nexthop via 10.11.1.2 nexthop via 10.11.2.2
> ip li del dummy2
>
> --> the entire multipath route has been deleted.
>
>
> And, fixing this bug enables work to make IPv4 append to be sane -- appending a route should modify an existing route by adding the nexthop, not adding a new route that I believe can never actually be hit.
>
> Both cases mean modifying an IPv4 route -- adding or removing nexthops -- a capability that IPv6 allows so fixing this means closing another difference between the stacks.

good point on the bug you point out. agree the bug needs to be fixed ...but routing daemons react to this behavior pretty well...because they get a link notification and a route notification. I was ok with fixing ipv6 to be similar to ipv4...but I am not in favor of bringing in design choices that ipv6 made into ipv4 :).
In all cases, in my experience with routes, the update of ecmp route as a whole has always been ok (at-least not until now...maybe in the future
for new usecases)

In the case of the bug you point out, can the user be notified of the implicit update of the route in the kernel ...via replace flag or something ?.
regarding append..., ipv4 never really supported appending to an existing route......even in the case of a non-ecmp routes.
append just dictates the order where the route is added IIRC  (i maybe mistaken here..its been long i tried it).
