From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 1/1] net sched actions: fix GETing actions
Date: Thu, 15 Sep 2016 19:33:02 -0400 (EDT)
Message-ID: <20160915.193302.677247650007637133.davem@davemloft.net>
References: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbcIOXdF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:33:05 -0400
In-Reply-To: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 12 Sep 2016 19:07:38 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> With the batch changes that translated transient actions into
> a temporary list lost in the translation was the fact that
> tcf_action_destroy() will eventually delete the action from
> the permanent location if the refcount is zero.
> 
> Example of what broke:
> ...add a gact action to drop
> sudo $TC actions add action drop index 10
> ...now retrieve it, looks good
> sudo $TC actions get action gact index 10
> ...retrieve it again and find it is gone!
> sudo $TC actions get action gact index 10
> 
> Fixes:
> commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> commit 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> commit f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Please incorporate Sergei's feedback and resubmit, thanks Jamal.
