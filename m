From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] mpls: multipath support
Date: Tue, 06 Oct 2015 13:31:44 -0700
Message-ID: <56142FB0.1070002@cumulusnetworks.com>
References: <1444157209-12518-2-git-send-email-roopa@cumulusnetworks.com> <87vbajbx4l.fsf@x220.int.ebiederm.org> <87612jbvu8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35123 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbJFUbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 16:31:45 -0400
Received: by pacfv12 with SMTP id fv12so224404674pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 13:31:44 -0700 (PDT)
In-Reply-To: <87612jbvu8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/15, 1:11 PM, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
>
>> Roopa Prabhu <roopa@cumulusnetworks.com> writes:
>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch adds support for MPLS multipath routes.
>>>
>>> Includes following changes to support multipath:
>>> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'
>>>
>>> - 'struct mpls_nh' represents a mpls nexthop label forwarding entry
>>>
>>> - moves mpls route and nexthop structures into internal.h
>>>
>>> - A mpls_route can point to multiple mpls_nh structs
>>>
>>> - the nexthops are maintained as a list
>> So I am not certain I like nexthops being a list.  In the practical case
>> introducing this list guarantees that everyone will see at least an
>> extra cache line miss in the forwarding path.
>>
>> In the more abstract sense a list is the wrong data structure.  If the
>> list is so short we can afford to walk it an array is a better data
>> structure.  If we need enough entries to make the memory consumption
>> of an array a concern we want some kind of hash table or tree data
>> structure, because a list will be too long in that case.
>>
>> So can we please not use a list?
>>
>> I expect we can simplify the data structures by noting that rt_via must
>> be an ethernet mac today so that 6 bytes are enough and 8 bytes gives us
>> a bit extra and aligns things nicely.
> Grr. My mistake.  The current worst case is 16 bytes for an ipv6
> address in rt_via.  But the point remains that a fixed sized array of
> bytes in rt_via allows the use of an array and not a list for nexthops.
>
> At least for the single nexthop case I really want something that is
> small enough it fits in a single 64byte cache line.  The performance
> compared to anything else is going to be noticable.
>
agree. Just responded to your last email. I moved from array to list only because of the extra bytes.
I would prefer an array too.

http://marc.info/?l=linux-netdev&m=143932956719398&w=2

or

https://patchwork.ozlabs.org/patch/506226/


link to full series is here: http://marc.info/?l=linux-netdev&m=143932955919395&w=2

thanks,
Roopa
