From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: iproute2 mpls max labels
Date: Fri, 22 Jul 2016 14:24:08 -0500
Message-ID: <878twtv5lz.fsf@x220.int.ebiederm.org>
References: <578A7BF0.2020107@nordu.net>
	<57911A26.3080203@cumulusnetworks.com>
	<8737n23goi.fsf@x220.int.ebiederm.org> <579139C2.1050804@nordu.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	Robert Shearman <rshearma@brocade.com>
To: Magnus Bergroth <bergroth@nordu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40396 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbcGVThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 15:37:08 -0400
In-Reply-To: <579139C2.1050804@nordu.net> (Magnus Bergroth's message of "Thu,
	21 Jul 2016 23:08:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Magnus Bergroth <bergroth@nordu.net> writes:

>> Eric W. Biederman <mailto:ebiederm@xmission.com>
>> a) I just looked and the kernel netlink protocol does not have a limit.
>>    The kernel does have a limit but the netlink protocol does not  so
>>    there is no point in exporting a limit in a uapi header,  it will
>>    just be out of date and wrong.
>>
>> b) I can see in principle bumping up the kernels MAX_LABELS past two
>>    although I haven't heard those requests, or understand the use cases.
>>    I don't recall seeing any ducumentation on cases where it is
>>    desirable to push a lot of labels at once.  (Do hardware
>>    implementations support pushing a lot of labels at once?)
>>
>>    Bumping past 8 seems quite a lot.  That starts feeling like people
>>    trying to break other peoples mpls stacks.  That is asking for more
>>    packet space for labels than ipv6 uses for addresses and ipv6 is way
>>    oversized.  The commonly agreed wisdom is the world only needs 40 to
>>    48 bits to route on to reach the entire world.  
> I think that 8 would be more than enough for most use cases, even 6 or 4
> would be sufficient. I'm looking at doing MPLS source routing based on a
> label-stack. Each router in the network will get a set of static routes
> that pop the label and sends it out to the next router based on the
> label that gets poped.  I have no problem compiling a special build with
> the MAX_LABELS set to my need. I just noticed that changing only the
> MAX_LABELS wasn't enough to get more than 8 labels to work with iproute2
> after changing the kernel "MAX_NEW_LABELS 2" in
> include/net/mpls_iptunnel.h  and net/mpls/internal.h to a higher
> number.

At a practical level in general it doesn't make sense to support special
builds.  The code rarely get tested and so bit rots.  In a situation
like this it makes sense to dig in and solve the problem as generally as
you can as long as it doesn't cause problems for anything else.

Eric
