From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net_sched: Fail if missing mandatory action
 operation methods
Date: Tue, 03 Dec 2013 11:48:34 -0500 (EST)
Message-ID: <20131203.114834.106107332355850481.davem@davemloft.net>
References: <1386080600-4067-1-git-send-email-jhs@mojatatu.com>
	<1386080600-4067-6-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab3LCQsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:48:36 -0500
In-Reply-To: <1386080600-4067-6-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue,  3 Dec 2013 09:23:19 -0500

> @@ -277,8 +277,10 @@ int tcf_register_action(struct tc_action_ops *act)
>  			return -EEXIST;
>  		}
>  	}
> -	act->next = NULL;
> -	*ap = act;
> +
> +	/* Must supply act, dump, cleanup and init */
> +	if (!act->act || !act->dump || !act->cleanup || !act->init)
> +		return -EINVAL;
>  
>  	/* Supply defaults */
>  	if (!act->lookup)

You are going to return with a lock held on error here.

I was going to tell you not to do these fixups so late in the
function, inside of the write lock, there is no reason for it.

You should do all of this operation handling at the top of
the function, before the write lock is taken.
