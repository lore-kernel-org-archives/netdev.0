From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net v3 2/3] net_sched: fix reference counting of tc
 filter chain
Date: Tue, 12 Sep 2017 12:43:12 +0200
Message-ID: <20170912104312.GF2036@nanopsycho>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        jakub.kicinski@netronome.com, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36683 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdILKnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 06:43:15 -0400
Received: by mail-wr0-f193.google.com with SMTP id g50so5799062wra.3
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 03:43:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170911233332.7594-3-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 12, 2017 at 01:33:31AM CEST, xiyou.wangcong@gmail.com wrote:
>This patch fixes the following ugliness of tc filter chain refcnt:
>
>a) tp proto should hold a refcnt to the chain too. This significantly
>   simplifies the logic.
>
>b) Chain 0 is no longer special, it is created with refcnt=1 like any
>   other chains. All the ugliness in tcf_chain_put() can be gone!
>
>c) No need to handle the flushing oddly, because block still holds
>   chain 0, it can not be released, this guarantees block is the last
>   user.
>
>d) The race condition with RCU callbacks is easier to handle with just
>   a rcu_barrier(). Much easier to understand, nothing to hide. Thanks
>   to the previous patch. Please see also the comments in code.
>
>e) Make the code understandable by humans, much less error-prone.
>
>Fixes: 744a4cf63e52 ("net: sched: fix use after free when tcf_chain_destroy is called multiple times")
>Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>Cc: Jiri Pirko <jiri@mellanox.com>
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looking good to me. Thanks!

Acked-by: Jiri Pirko <jiri@mellanox.com>
