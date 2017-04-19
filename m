From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 07:53:02 -0400
Message-ID: <767cf945-a1c7-fa24-4d30-2cde4f3e1a60@mojatatu.com>
References: <1492602564-9100-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35083 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762277AbdDSLxF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 07:53:05 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so3134077iof.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 04:53:05 -0700 (PDT)
In-Reply-To: <1492602564-9100-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 07:49 AM, Jamal Hadi Salim wrote:
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
>
> Some results dumping 1.5M actions, first unpatched tc which the
> kernel doesnt help:
>
> prompt$ time -p tc actions ls action gact | grep index | wc -l
> 1500000
> real 1388.43
> user 2.07
> sys 1386.79
>
> Now lets see a patched tc which sets the correct flags when requesting
> a dump:
>
> prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
> 1500000
> real 178.13
> user 2.02
> sys 176.96
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  MAINTAINERS                    |  1 +
>  include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++++--
>  net/sched/act_api.c            | 43 ++++++++++++++++++++++++++++++++----------
>  3 files changed, 53 insertions(+), 12 deletions(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 7b4b828..94eadbc 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -12198,6 +12198,7 @@ F:	kernel/taskstats.c
>
>  TC subsystem
>  M:	Jamal Hadi Salim <jhs@mojatatu.com>
> +M:	Jamal Hadi Salim <jhs@mojatatu.com>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>  F:	include/net/pkt_cls.h

Grrr. I did it again. Sending v4 shortly

cheers,
jamal
