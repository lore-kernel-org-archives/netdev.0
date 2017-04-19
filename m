From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than TCA_ACT_MAX_PRIO
 actions per batch
Date: Tue, 18 Apr 2017 21:55:00 -0700
Message-ID: <58F6EDA4.6090601@cumulusnetworks.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34044 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758961AbdDSEzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 00:55:02 -0400
Received: by mail-pf0-f174.google.com with SMTP id c198so6615399pfc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 21:55:02 -0700 (PDT)
In-Reply-To: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/17, 6:14 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> When you dump hundreds of thousands of actions, getting only 32 per
> dump batch even when the socket buffer and memory allocations allow
> is inefficient.
>
> With this change, the user will get as many as possibly fitting
> within the given constraints available to the kernel.
>
> A new top level TLV space is introduced. An attribute
> TCAA_ACT_FLAGS is used to carry the flags indicating the user
> is capable of processing these large dumps. Older user space which
> doesnt set this flag doesnt get the large (than 32) batches.
> The kernel uses the TCAA_ACT_COUNT attribute to tell the user how many
> actions are put in a single batch. As such user space app knows how long
> to iterate (independent of the type of action being dumped)
> instead of hardcoded maximum of 32.
Is the count attribute really needed ?. user space knows how to iterate multiple
attributes of the same type till the end of msg. eg. fdb dumps don't use count.
