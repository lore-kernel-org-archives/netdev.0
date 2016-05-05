From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack
 tables, part 1
Date: Thu, 5 May 2016 22:54:18 +0200
Message-ID: <20160505205418.GA21687@breakpoint.cc>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <572BACA3.6070303@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hpe.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <572BACA3.6070303@hpe.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley <brian.haley@hpe.com> wrote:
> Openstack networking creates virtual routers using namespaces for isolation
> between users.  VETH pairs are used to connect the interfaces on these
> routers to different networks, whether they are internal (private) or
> external (public).  In most cases NAT is done inside the namespace as
> packets move between the networks.
> 
> I've seen cases where certain users are attacked, where the CT table is
> filled such that we start seeing "nf_conntrack: table full, dropping packet"
> messages (as expected).  But other users continue to function normally,
> unaffected.  Is this still the case - each netns has some limit it can't
> exceed?

The limit is global, the accounting per namespace.

If the bucket count (net.netfilter.nf_conntrack_buckets) is high enough
to accomodate the expected load and noone can create arbitrary number of
net namespaces things are fine.

I haven't changed the way this works yet because I did not have a better
idea so far.
