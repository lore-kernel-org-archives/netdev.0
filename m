From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 4/4] net sched actions: add time filter for
 action dumping
Date: Mon, 24 Jul 2017 13:34:50 +0200
Message-ID: <20170724113450.GD1868@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-5-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35566 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752772AbdGXLez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 07:34:55 -0400
Received: by mail-wm0-f67.google.com with SMTP id m75so8496800wmb.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 04:34:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1500860146-26970-5-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 24, 2017 at 03:35:46AM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>This patch adds support for filtering based on time since last used.
>When we are dumping a large number of actions it is useful to
>have the option of filtering based on when the action was last
>used to reduce the amount of data crossing to user space.
>
>With this patch the user space app sets the TCA_ROOT_TIME_DELTA
>attribute with the value in milliseconds with "time of interest
>since now".  The kernel converts this to jiffies and does the
>filtering comparison matching entries that have seen activity
>since then and returns them to user space.
>Old kernels and old tc continue to work in legacy mode since
>they dont specify this attribute.

[...]


>@@ -128,6 +129,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
> 			if (index < s_i)
> 				continue;
> 
>+			if (jiffy_since &&
>+			    time_after(jiffy_since,
>+				       (unsigned long)p->tcfa_tm.lastuse))

You don't need to check jiffy_since==0. Also, nicer  ^^ this with a space :)

Other than this, looks fine. Thanks.
