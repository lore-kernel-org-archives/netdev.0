From: Brian Haley <brian.haley@hpe.com>
Subject: Re: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack tables,
 part 1
Date: Thu, 5 May 2016 18:22:29 -0400
Message-ID: <572BC7A5.1060503@hpe.com>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <572BACA3.6070303@hpe.com> <20160505205418.GA21687@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:55941 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbcEEWWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 18:22:39 -0400
In-Reply-To: <20160505205418.GA21687@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/2016 04:54 PM, Florian Westphal wrote:
> Brian Haley <brian.haley@hpe.com> wrote:
>> Openstack networking creates virtual routers using namespaces for isolation
>> between users.  VETH pairs are used to connect the interfaces on these
>> routers to different networks, whether they are internal (private) or
>> external (public).  In most cases NAT is done inside the namespace as
>> packets move between the networks.
>>
>> I've seen cases where certain users are attacked, where the CT table is
>> filled such that we start seeing "nf_conntrack: table full, dropping packet"
>> messages (as expected).  But other users continue to function normally,
>> unaffected.  Is this still the case - each netns has some limit it can't
>> exceed?
>
> The limit is global, the accounting per namespace.

So this is a change from existing.

> If the bucket count (net.netfilter.nf_conntrack_buckets) is high enough
> to accomodate the expected load and noone can create arbitrary number of
> net namespaces things are fine.

In my case we can't control the number of namespaces, each user will get one as 
a virtual router is created.  We could change how we size things, but that 
doesn't stop one user from consuming larger than their 1/N share of entries. 
Typically we just increase the number of systems hosting these "routers" when we 
hit a limit, which decreases the netns count per node.

> I haven't changed the way this works yet because I did not have a better
> idea so far.

Creating a per-netns maximum seems doable, but maybe not practical from the 
accounting side of things.  Can't think of anything else at the moment.

-Brian
