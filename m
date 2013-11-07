From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: ipv6: a question about ECMP
Date: Thu, 7 Nov 2013 13:32:15 -0500
Message-ID: <CACP96tRh345x4D1BqpOK2eWfoeVbqMnu-+jGfF7eyFC1dbQoug@mail.gmail.com>
References: <527B6C70.3010507@cn.fujitsu.com>
	<20131107121602.GI8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42743 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab3KGScQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 13:32:16 -0500
Received: by mail-la0-f46.google.com with SMTP id el20so777999lab.33
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 10:32:15 -0800 (PST)
In-Reply-To: <20131107121602.GI8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 7, 2013 at 7:16 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Duan!
>
> On Thu, Nov 07, 2013 at 06:33:20PM +0800, Duan Jiong wrote:
>>   After reading the ip6_pol_route(), i have a question about ECMP. Why we call
>> the rt6_multipath_select() after calling rt6_select()?
>>   In my opinion, the route returned by rt6_select() has a highest score, but the route
>> returned by rt6_multipath_select() may has a lower score than the former, because the
>> ECMP don't take the route preference into consideration. That means that the kernel will
>> choose a less-desirable route.
>
> ECMP routes only differ in the gateway the specify, so I doubt there will be
> any change in the score they woud receive. rt6_multipath_select does merly
> make sure we don't select the same route again and again.

 rt6_multipath_select() -> rt6_socre_route() seems to require that the
interface *must* matchi, which is consistent with your assertion above that
"ECMP routes differ in gw only".

But for IPv6, the gw addr is a a link-local, which is only required to be
unique on the link. Thus, e.g.,  you can have fe80::1 as the gw on both eth0 and
eth1.

What is the assumption around "cost" for ECMP here- are we assuming some
form of link bundling (Section 6 of rfc 2991) here? or is the "multiple parallel
links" case handled somewhere else, that I am missing?

--Sowmini

>
> Please note, the rt6_info's siblings fields were added for the solely purpose
> of ECMP and the insertion only updates the siblings list if the above criteria
> did hold. They make sure the routes lookup up do differ on each lookup, so it
> does actually do multipath and does not depend on the order the routes where
> inserted.
>
> Hope that helps,
>
>   Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
