From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v12 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Sun, 30 Jul 2017 21:05:34 +0200
Message-ID: <20170730190534.GC1872@nanopsycho>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38408 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754479AbdG3TFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 15:05:44 -0400
Received: by mail-wr0-f194.google.com with SMTP id g32so12820179wrd.5
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 12:05:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1501435492-28301-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 30, 2017 at 07:24:51PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>When you dump hundreds of thousands of actions, getting only 32 per
>dump batch even when the socket buffer and memory allocations allow
>is inefficient.
>
>With this change, the user will get as many as possibly fitting
>within the given constraints available to the kernel.
>
>The top level action TLV space is extended. An attribute
>TCA_ROOT_FLAGS is used to carry flags; flag TCA_FLAG_LARGE_DUMP_ON
>is set by the user indicating the user is capable of processing
>these large dumps. Older user space which doesnt set this flag
>doesnt get the large (than 32) batches.
>The kernel uses the TCA_ROOT_COUNT attribute to tell the user how many
>actions are put in a single batch. As such user space app knows how long
>to iterate (independent of the type of action being dumped)
>instead of hardcoded maximum of 32 thus maintaining backward compat.
>
>Some results dumping 1.5M actions below:
>first an unpatched tc which doesnt understand these features...
>
>prompt$ time -p tc actions ls action gact | grep index | wc -l
>1500000
>real 1388.43
>user 2.07
>sys 1386.79
>
>Now lets see a patched tc which sets the correct flags when requesting
>a dump:
>
>prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>1500000
>real 178.13
>user 2.02
>sys 176.96
>
>That is about 8x performance improvement for tc app which sets its
>receive buffer to about 32K.
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

If DavidA is ok with the "validation_data", I am fine with this patch.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
