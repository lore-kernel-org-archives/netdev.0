From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/2] net_sched: refactor notification code for
 RTM_DELTFILTER
Date: Sun, 6 Aug 2017 07:42:13 -0400
Message-ID: <7b8c926f-8c28-b403-e380-c6ae521c9cc0@mojatatu.com>
References: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
 <20170805043143.13680-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34001 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdHFLmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 07:42:23 -0400
Received: by mail-io0-f193.google.com with SMTP id m88so3742184iod.1
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 04:42:23 -0700 (PDT)
In-Reply-To: <20170805043143.13680-2-xiyou.wangcong@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-05 12:31 AM, Cong Wang wrote:
> It is confusing to use 'unsigned long fh' as both a handle
> and a pointer, especially commit 9ee7837449b3
> ("net sched filters: fix notification of filter delete with proper handle").
> 
> This patch introduces tfilter_del_notify() so that we can
> pass it as a pointer as before, and we don't need to check
> RTM_DELTFILTER in tcf_fill_node() any more.
>
> This prepares for the next patch.
>


Looks good to me.
A small question below:


> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   net/sched/cls_api.c | 44 +++++++++++++++++++++++++++++++++++++++-----
>   1 file changed, 39 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index e655221c654e..afd099727aea 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -104,6 +104,10 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
>   			  struct nlmsghdr *n, struct tcf_proto *tp,
>   			  unsigned long fh, int event, bool unicast);
>   
> +static int tfilter_del_notify(struct net *net, struct sk_buff *oskb,
> +			      struct nlmsghdr *n, struct tcf_proto *tp,
> +			      unsigned long fh, bool unicast, bool *last);
> +

Any reason not to move the functin up here and getting rid of this
forward declaration?

otherwise:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
