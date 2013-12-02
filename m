From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net_sched: actions - Add default lookup and walker
Date: Mon, 02 Dec 2013 16:27:52 -0500 (EST)
Message-ID: <20131202.162752.2143617473594386587.davem@davemloft.net>
References: <1385937009-589-1-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591Ab3LBV14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 16:27:56 -0500
In-Reply-To: <1385937009-589-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun,  1 Dec 2013 17:30:05 -0500

> This set of patches provide defaults for lookup and walkers for actions.
> Users can override when needed.
> 
> Jamal Hadi Salim (4):
>   Provide default lookup function for actions that dont provide one
>   Use default lookup functions. Users are free to override when needed.
>   Provide default walker function for actions that dont provide one
>   Use default walker functions. Users who need something special can
>     override.

Ok, but can you respin this set, adding in changes to remove
the code that checks for NULL in these operations?

Specifically, we still have:

	if (a->ops->lookup == NULL)
		goto err_mod;

in tcf_action_get_1().  And:

	if (a_o->walk == NULL) {

in tc_dump_action().

Furthermore, there is a hard assumption that a_o->init() is non-NULL
as well.  So maybe add a:

	if (!act->init)
		return -EINVAL;

at the top of tcf_register_action().

It also occurred to me that it would be simpler to audit and be a
simpler patch set to review if you just added the missing ".lookup ="
assignments to the actions and added a similar "if (!act->lookup)" et
al. check to tcf_register_action().

That looks more like a rigorous requirement to have a valid method
present for these three operations: init, lookup, walk.

What do you think?

Thanks!
