From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/9] genetlink: reduce ops size and complexity (v2)
Date: Fri, 15 Nov 2013 14:18:35 +0100
Message-ID: <1384521515.14295.2.camel@jlt4.sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
	 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
	 <20131114.171204.1979806323628158355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wimax@intel.com,
	bsingharora@gmail.com, netfilter-devel@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131114.171204.1979806323628158355.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-14 at 17:12 -0500, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 14 Nov 2013 17:14:38 +0100
> 
> > As before - reduce the complexity and data/code size of genetlink ops
> > by making them an array rather than a linked list. Most users already
> > use an array thanks to genl_register_family_with_ops(), so convert the
> > remaining ones allowing us to get rid of the list head in each op.
> > 
> > Also make them const, this just makes sense at that point and the security
> > people like making function pointers const as well :-)
> 
> I have to say, this is an absolutely fantastic space usage and
> complexity improvement.

:-)

FWIW, we can also clean up the two registration functions now and make
it just a single one (actually we could have done that before as well,
passing NULL for ops, but hey, now it's even easier). I'll send a patch
for that.

I've been eyeing the multicast groups as well, but the code using them
is nicer if it's not an array. With an array, you'd have to do something
like

send_event(&my_mcast_groups[1]);

instead of

send_event(&my_foo_mcast_group);

which is a bit odd.

We could instead register an array of pointers to the groups:

static const struct mcast_group *my_groups[] = {
	&my_foo_mcast_group,
	...
};

and pass this to the family - that'd still be less space (one pointer
for each group rather than two in a linked list) and still allow all
groups and this array to be const, but it's not quite as big a
saving ...

Thoughts?

johannes


