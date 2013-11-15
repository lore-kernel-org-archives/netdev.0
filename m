From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/9] genetlink: reduce ops size and complexity (v2)
Date: Fri, 15 Nov 2013 09:45:22 -0500
Message-ID: <52863382.2060309@mojatatu.com>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>	 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>	 <20131114.171204.1979806323628158355.davem@davemloft.net>	 <1384521515.14295.2.camel@jlt4.sipsolutions.net> <1384521794.14295.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wimax@intel.com,
	bsingharora@gmail.com, netfilter-devel@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384521794.14295.5.camel@jlt4.sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Are we killing APIs that are already used?
At least that patches that Dave sucked in do. Out of tree
users dont matter?

cheers,
jamal

On 11/15/13 08:23, Johannes Berg wrote:
> On Fri, 2013-11-15 at 14:18 +0100, Johannes Berg wrote:
>
>> I've been eyeing the multicast groups as well
>
> Of course, there are also *much* fewer mcast groups, so the saving isn't
> nearly as big. But we still have some oddball code to register them all,
> basically
>
> 	err = register_mc_group();
> 	if (err)
> 		goto unregister_family;
>
> (since we have to register the family first, afaict)
>
> sometimes a few of those back to back, and it'd be nicer on the users if
> that just went away and was
>
> 	family.mcast_groups = my_groups;
> 	family.n_mcast_groups = ARRAY_SIZE(my_groups);
> 	family.ops = my_ops;
> 	family.n_ops = ARRAY_SIZE(my_ops);
> 	return genl_register_family(&family);
>
> since nobody uses them dynamically anyway, afaict.
>
> johannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

