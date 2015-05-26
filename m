From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] mpls: fix mpls route deletes to not check for route
 scope and type
Date: Tue, 26 May 2015 15:02:33 -0700
Message-ID: <5564ED79.7050604@cumulusnetworks.com>
References: <1432674867-63142-1-git-send-email-roopa@cumulusnetworks.com> <87bnh7yprc.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36299 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbEZWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 18:02:36 -0400
Received: by paza2 with SMTP id a2so93266673paz.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 15:02:35 -0700 (PDT)
In-Reply-To: <87bnh7yprc.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/26/15, 2:48 PM, Eric W. Biederman wrote:
> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch fixes incorrect -EINVAL error due to invalid
>> scope and type for mpls route deletes.
> Well this is embarrassing apparently I did not exercise this code path
> in iproute.
>
> Looking through my tests the closest I came was:
> ip -M route flush table all
>
>> iproute2 route modify code does not set protocol/scope/type
>> for RTM_DELROUTE msgs. mpls code can skip checking for
>> these too.
> I am really not certain that is the case.  I expect if you check
> you will find that rtm_scope is set to 0  aka RT_SCOPE_UNIVERSE.
>
> For scope I don't much care.  The mpls concepts and the ip concepts
> don't match.  With mpls packets can be sent from anywhere in the
> universe to an address that is valid only on one link.
>
> For rtm_type I think we do care.  IPv4 and IPv6 are a disaster when it
> comes to interfaces for setting up multicast routes, and I don't see any
> reason why we would need to replicate that disaster for mpls.
>
> As such I would like rtm_type to actually mean something, as for mpls
> the lookup for multicast packets and the lookup for unicast packets is
> completely different.  Unicast packet addresses are defined by the
> receiver, and multicast packet addresses are defined by the sender.
>
> So can we instead fix iproute to set rtm_type == RTN_UNICAST?
> At least for mpls.
>
>
yes sure. I started with handling this in iproute2. So, i do have an 
iproute2 patch for this.
Will post it later today.

thanks.
