From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Basic MPLS support
Date: Fri, 27 Feb 2015 16:21:31 -0500 (EST)
Message-ID: <20150227.162131.431559184124647735.davem@davemloft.net>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbbB0VVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 16:21:34 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 25 Feb 2015 11:09:23 -0600

> While trying to figure out what MPLS is and why MPLS support is not in
> the kernel on a lark I sat down and wrote an MPLS implemenation, so I
> could answer those questions for myself.
> 
> From what I can tell the short answer is MPLS is trivial-simple and the
> we don't have an in-kernel implementation because no one has sat down
> and done the work to have a good mergable implementation.
> 
> MPLS has it's good sides and it's bad sides but at the end of the day
> MPLS has users, and having an in-kernel implementation should help us
> understand MPLS and focus our conversations dealing with MPLS and
> VRFs.
> 
> Having MPLS in our toolkit as the entire world begins playing with
> overlay networks aka ``network virtualization'' to support VM and
> container migration seems appropriate as MPLS is the historical solution
> to this problem.
> 
> Constructive criticism about the netlink interface is especially
> appreciated.  Hopefully we can have at least one protocol in the kernel
> where the netlink interface doesn't have nasty corner case.
> 
> As for linux users.  The conversations I had at netdev01 this sounds
> like a case of if I build it people will use the code.

At a high level I have no objections to this work and I'm in fact
extremely happy to see someone working on this.

However I would ask you to reconsider the neighbour handling issue.

It seems to me that routing daemons are going to more naturally work
with ipv4 addresses as MPLS next hops, and therefore when that's the
case we should too.

Why?

Because then the neighbour layer handles failover transparently for
you.

Think about it, if we have a case where some other resolving mechanism
would be used for MPLS nexthops, there would need to be some kind of
fail over handling mechanism for it as well.
