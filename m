From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/4] net_sched: actions - Add default lookup and walker
Date: Tue, 03 Dec 2013 08:34:12 -0500
Message-ID: <529DDDD4.6070706@mojatatu.com>
References: <1385937009-589-1-git-send-email-jhs@mojatatu.com> <20131202.162752.2143617473594386587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36041 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab3LCNeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 08:34:22 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so23241269iej.40
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 05:34:21 -0800 (PST)
In-Reply-To: <20131202.162752.2143617473594386587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/13 16:27, David Miller wrote:
>
> Ok, but can you respin this set, adding in changes to remove
> the code that checks for NULL in these operations?
>
> Specifically, we still have:
>
> 	if (a->ops->lookup == NULL)
> 		goto err_mod;
>
> in tcf_action_get_1().  And:
>
> 	if (a_o->walk == NULL) {
>
> in tc_dump_action().
>

Ok, I think i finaly understood what you were saying earlier;->
I was too focused on the simple fix needed for Eric B.
Will make this change ..

> Furthermore, there is a hard assumption that a_o->init() is non-NULL
> as well.  So maybe add a:
>
> 	if (!act->init)
> 		return -EINVAL;
>
> at the top of tcf_register_action().
>

Makes sense.

> It also occurred to me that it would be simpler to audit and be a
> simpler patch set to review if you just added the missing ".lookup ="
> assignments to the actions

Those two methods have proven to be always the defaults and only the
oddball action deviates. So my preference is to have defaults as per
that earlier patch (and overrides for the oddball).


 >and added a similar "if (!act->lookup)" et
> al. check to tcf_register_action().
>
> That looks more like a rigorous requirement to have a valid method
> present for these three operations: init, lookup, walk.
>
> What do you think?

Yep - makes sense (I think you meant act, dump, cleanup and init)
I will add an extra patch..

cheers,
jamal


> Thanks!
>
