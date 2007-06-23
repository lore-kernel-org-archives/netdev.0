From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 13:08:25 -0600
Message-ID: <m1vede8p5i.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
	<467D5FCD.4080003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Ben Greear <greearb@candelatech.com>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33175 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbXFWT1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 15:27:34 -0400
In-Reply-To: <467D5FCD.4080003@trash.net> (Patrick McHardy's message of "Sat,
	23 Jun 2007 20:00:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>>>>Depending upon the data structure it will either be modified to hold
>>>>a per entry network namespace pointer or it there will be a separate
>>>>copy per network namespace.  For large global data structures like
>>>>the ipv4 routing cache hash table adding an additional pointer to the
>>>>entries appears the more reasonable solution.
>>>
>>>
>>>So the routing cache is shared between all namespaces?
>> 
>> 
>> Yes.  Each namespaces has it's own view so semantically it's not
>> shared.  But the initial fan out of the hash table 2M or something
>> isn't something we want to replicate on a per namespace basis even
>> assuming the huge page allocations could happen.
>> 
>> So we just tag the entries and add the network namespace as one more
>> part of the key when doing hash table look ups.
>
>
> I can wait for the patches, but I would be interested in how
> GC is performed and whether limits can be configured per
> namespace.

Currently I believe the gc code is unmodified in my patches.

Currently I have been focusing on the normal semantics and just
making something work in a mergeable fashion.

Limits and the like are comparatively easy to add in after the
rest is working so I haven't been focusing on that.

Eric
