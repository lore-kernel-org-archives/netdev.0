From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/7] Basic MPLS support take 2
Date: Wed, 04 Mar 2015 00:13:14 -0600
Message-ID: <8761ahp9xh.fsf@x220.int.ebiederm.org>
References: <20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
	<87vbihtvts.fsf_-_@x220.int.ebiederm.org>
	<20150304.002734.1453464446418392919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org,
	horms@verge.net.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39645 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759205AbbCDGQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 01:16:49 -0500
In-Reply-To: <20150304.002734.1453464446418392919.davem@davemloft.net> (David
	Miller's message of "Wed, 04 Mar 2015 00:27:34 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 03 Mar 2015 19:06:39 -0600
>
>> On top of my two pending neighbour table prep patches here is the mpls
>> support refactored to use them, and edited to not drop routes when
>> an interface goes down.  Additionally the addition of RTA_LLGATEWAY
>> has been replaced with the addtion of RTA_VIA.  RTA_VIA being an
>> attribute that includes the address family as well as the address
>> of the next hop.
>> 
>> MPLS is at it's heart simple and I have endeavoured to maintain that
>> simplicity in my implemenation.
>> 
>> This is an implementation of a RFC3032 forwarding engine, and basic MPLS
>> egress logic.  Which should make linux sufficient to be a mpls
>> forwarding node or to be a LSA (Label Switched Router) as it says in all
>> of the MPLS documents.  The ingress support will follow but it deserves
>> it's own discussion so I am pushing it separately.
>
> Ok, with the neigh changes, I think I'm fine with this.
>
> Series applied, thanks.
>
> Please think very carefully about the netlink API you've created to
> config this stuff, once we hit the next merge window we will be stuck
> with this thing forever.

I have done my best to keep things minimal so only the bare essentials
are present at this point.

I will also take suggestions from anyone else who has a thought.

What I worry most about is the table table size is a sysctl and
thus table size changes, and notifications don't happen over netlink.

I have done my best with the netlink API and other than the above table
size issue I don't have any real reservations.

I do worry about the alignment of struct rtvia.  A 16bit field before
addresses is not exactly ideal for address alignment.  But short of
wasting space I don't see any real good alternatives.

If and when we implement forwarding of MPLS multicast there will have
to be some interesting changes.  Instead of having destination specific
addresses there are source specific addresses so a RTA_NEWSRC attribute
will probably have to be added to complement the RTA_NEWDST attribute.

But in essence that all fits into the existing routing message model
and iproute2 has required very minimal changes so far. 

Is there a standard location to document netlink messages?  I don't
think I have tripped over one at this point.

I hope this gets us to the point where other folks who care about mpls
can jump in and make incremental improvements.

Eric
