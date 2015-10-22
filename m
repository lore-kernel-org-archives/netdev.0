From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 0/2] mpls: multipath support
Date: Thu, 22 Oct 2015 06:35:38 -0700
Message-ID: <5628E62A.8090607@cumulusnetworks.com>
References: <1445217645-42885-1-git-send-email-roopa@cumulusnetworks.com> <87zizbczvz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34744 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755666AbbJVNfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:35:40 -0400
Received: by padhk11 with SMTP id hk11so87305912pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 06:35:39 -0700 (PDT)
In-Reply-To: <87zizbczvz.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/15, 9:04 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds support for MPLS multipath routes.
>>
>> Includes following changes to support multipath:
>> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'.
>>
>> - struct mpls_nh represents a mpls nexthop label forwarding entry
>>
>> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
>> multipath routes similar to ipv4/v6 fib
>>
>> - In the process of restructuring, this patch also consistently changes all
>> labels to u8
>>
>> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
>> 		nexthop as 700 via inet 10.1.1.6 dev swp2 \
>> 		nexthop as 800 via inet 40.1.1.2 dev swp3
>>
>> $ip  -f mpls route show
>> 100 
>> 	nexthop as to 200 via inet 10.1.1.2  dev swp1
>> 	nexthop as to 700 via inet 10.1.1.6  dev swp2
>> 	nexthop as to 800 via inet 40.1.1.2  dev swp3
>>
>> Roopa Prabhu (1):
>>   mpls: multipath support
>>
>> Robert Shearman (1):
>>   mpls: flow-based multipath selection
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> ----
>> v2:
>> 	- Incorporate some feedback from Robert:
>> 		use dynamic allocation (list) instead of static allocation
>> 		for nexthops
>> v3:
>> 	- Move back to arrays (same as v1), also suggested by Eric Biederman
>>
>> v4:
>> 	- address a few comments from Eric Biederman
>> 	Plan to address the following pending comments in incremental patches after this
>> 	infrastructure changes go in.
>> 	- Move VIA size to 16 bytes
>> 	- use ipv6 flow label in ecmp calculations
>> 	- dead route handling during multipath route selection (I had planned this in
>> 	an incremental patch initially).
> I don't see anything problematic in the patches the worst
> I found is dead code and we can delete that later so
> for purposes of moving forward I say:
>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
> That said we really need dead path handling.  Without handling paths
> that go dead this functionality really is pretty much broken.  So if you
> can't get that by the merge window we will need to apply a patch to
> disable processing of the RTA_MULTIPATH netlink attribute.
I will submit these before the merge window. Since dead routes were not handled for the non-multipath routes, it always was an incremental feature to cover on my TODO list. Understand your concern, I will submit them soon.

thanks.
