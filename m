From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get tunnel
 routes and add dst_cache
Date: Wed, 20 Sep 2017 17:37:52 +0200
Message-ID: <01c68c74-455c-9bff-e5bb-b1708d8f92f4@tpip.net>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-4-tom@quantonium.net>
 <20170918.211751.1871429944584121281.davem@davemloft.net>
 <20170919120942.dpy5kmkhzws7pqd5@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Harald Welte <laforge@gnumonks.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:38721 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751507AbdITPhz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 11:37:55 -0400
In-Reply-To: <20170919120942.dpy5kmkhzws7pqd5@nataraja>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 19/09/17 14:09, Harald Welte wrote:
> Hi Dave,
> 
> On Mon, Sep 18, 2017 at 09:17:51PM -0700, David Miller wrote:
>> This and the new dst caching code ignores any source address selection
>> done by ip_route_output_key() or the new tunnel route lookup helpers.
>>
>> Either source address selection should be respected, or if saddr will
>> never be modified by a route lookup for some specific reason here,
>> that should be documented.
> 
> The IP source address is fixed by signaling on the GTP-C control plane
> and nothing that the kernel can unilaterally decide to change.  Such a
> change of address would have to be decided by and first be signaled on
> GTP-C to the peer by the userspace daemon, which would then update the
> PDP context in the kernel.

I think we had this discussion before. The sending IP and port are not 
part of the identity of the PDP context. So IMHO the sender is permitted
to change the source IP at random.

Regards
Andreas

> 
> So I guess you're asking us to document that rationale as form of a
> source code comment ?
> 
