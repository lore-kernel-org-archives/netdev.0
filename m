From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Thu, 25 Sep 2014 22:06:59 +0200
Message-ID: <542475E3.6030508@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com> <54243C89.6060405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939AbaIYUH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 16:07:26 -0400
In-Reply-To: <54243C89.6060405@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2014 06:02 PM, David L Stevens wrote:
> While I can see the case you're making, I think the intent of MRC is
> violated by arbitrary URI.
>
>> 5.1.3.  Maximum Response Code
>>
>>     The Maximum Response Code field specifies the maximum time allowed
>>     before sending a responding Report.
>> ...
>>     Small values of Maximum Response Delay allow MLDv2 routers to tune
>>     the "leave latency" (the time between the moment the last node on a
>>     link ceases to listen to a specific multicast address and the moment
>>     the routing protocol is notified that there are no more listeners for
>>     that address).  Larger values, especially in the exponential range,
>>     allow the tuning of the burstiness of MLD traffic on a link.
>
> If URI is larger than MRD, then a lost unsolicited report, or series,
> specifically will *not* propagate changes throughout the network in less
> than MRD*QRV, as intended.
>
> It was an intentional design choice, not required or prohibited by RFC.
>
> I'm not sure what problem you think it's causing, but if they are not
> equal, I think at least the URI should be enforced to <= MRD. The querier,
> IMO, should set these network-wide relevant parameters, not the individual
> hosts.

One of the problems I see (also with this argumentation -- next to the fact
that it's not specified by the RFC) is that we're blindly overwriting with
any given value from the MLDv2 query, while when temporarily transitioning
back to MLDv1 compatibility mode, we're simply ignoring any MLD value provided
from that query; both specifications also specify different default values for
URI, where we would have already overwritten a pre-configured URI default value
for v1 when we previously received a v2 query. While we have tunable for IPv4
case via commit 2690048c01f32 ("net: igmp: Allow user-space configuration of
igmp unsolicited report interval") and for IPv6 case via commit fc4eba58b4c1
("ipv6: make unsolicited report intervals configurable for mld"), this renders
any admin provided IPv6 specific configuration useless.

Thanks,
Daniel
