From: Julien Gomes <julien@arista.com>
Subject: Re: [PATCH net-next 0/3] ipmr/ip6mr: add Netlink notifications on
 cache reports
Date: Wed, 14 Jun 2017 14:51:35 -0700
Message-ID: <7b133850-bbdc-594c-f7f3-62e9d4adf1f3@arista.com>
References: <20170613170822.16310-1-julien@arista.com>
 <891d876f-18fb-706b-c269-ec8892d2f6ff@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Donald Sharp <sharpd@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:9629 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752080AbdFNVvg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 17:51:36 -0400
In-Reply-To: <891d876f-18fb-706b-c269-ec8892d2f6ff@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,

On 06/14/2017 05:04 AM, Nikolay Aleksandrov wrote:

> This has been on our todo list and I'm definitely interested in the implementation.
> A few things that need careful consideration from my POV. First are the security
> implications - this sends rtnl multicast messages but the rtnl socket has
> the NL_CFG_F_NONROOT_RECV flag thus allowing any user on the system to listen in.
> This would allow them to see the full packets and all reports (granted they can see
> the notifications even now), but the full packet is like giving them the opportunity
> to tcpdump the PIM traffic.

I definitely see how this can be an issue.
>From what I see, this means that either the packet should be
transmitted another way, or another Netlink family should be used.

NETLINK_ROUTE looks to be the logical family to choose though,
but then I do not see a proper other way to handle this.

However I may just not be looking into the right direction,
maybe you currently have another approach in mind?

> My second (more fixable and minor) concern is about the packet itself, how do you
> know that the packet is all linear so you can directly copy it ?

Indeed, I overlooked this possibility in this version.
I will improve that.

-- 
Julien Gomes
