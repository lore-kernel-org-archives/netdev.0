From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/2] lwtunnel: encap locally-generated ipv4 packets
Date: Tue, 4 Aug 2015 14:55:59 +0100
Message-ID: <55C0C46F.6000103@brocade.com>
References: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
 <55BFDFF3.2030309@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51783 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753487AbbHDN4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 09:56:16 -0400
In-Reply-To: <55BFDFF3.2030309@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/15 22:41, roopa wrote:
> On 8/3/15, 9:39 AM, Robert Shearman wrote:
>> Locally-generated IPv4 packets, such as from applications running on
>> the host or traceroute/ping currently don't have lwtunnel output
>> redirected encap applied. However, they should do in the same way as
>> for forwarded packets and this patch series addresses that.
>>
>> Robert Shearman (2):
>>    lwtunnel: set skb protocol and dev
>>    ipv4: apply lwtunnel encap for locally-generated packets
>>
>>   net/core/lwtunnel.c | 12 ++++++++++--
>>   net/ipv4/route.c    |  2 ++
>>   2 files changed, 12 insertions(+), 2 deletions(-)
>>
> Thanks for this patch Robert. Looks good.
> I have been thinking of sending a similar patch out for this and
> since i was also looking at ip fragmentation, I have a slightly
> different patch which I think should also take care of
> encapsulating locally generated packets too. This patch moves the output
> redirection to after ip fragmentation.
> What do you think about the below (I have briefly tested it. Was
> planning to test some more before sending it out as RFC) ?

I'm glad you're looking at fragmentation - this does need to be 
implemented at some point.

While it looks like fragmentation should work, the issue is that now 
post-routing netfilter modules will be presented with un-encapsulated 
packets without distinguishing them from encapsulated packets.

An example of why this is a problem is that this would prevent operators 
from implementing rules to prevent non-control IP packets being output 
onto an interface in an MPLS core, and I have seen service providers 
doing this sort of thing in the past. So I think this is a pretty big 
deal for MPLS. There are possibly other less obvious use cases that 
would be prevented by this change.

So as long as you can keep these working, I'd be fine with such an approach.

Thanks,
Rob
