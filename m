From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 22:34:28 -0700
Message-ID: <5428EF64.5030703@gmail.com>
References: <5425A545.1040907@gmail.com> <5425ED2D.1000005@mojatatu.com> <5425F5CC.4070507@intel.com> <542823CE.9020301@mojatatu.com> <CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com> <54284A51.5080805@gmail.com> <CAM_iQpVF8bHN8WNNH5kHyanj+fLE6kbsFOwQA+t_z_=UK_v=+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:51707 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaI2Feq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 01:34:46 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so1281752oia.17
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 22:34:45 -0700 (PDT)
In-Reply-To: <CAM_iQpVF8bHN8WNNH5kHyanj+fLE6kbsFOwQA+t_z_=UK_v=+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2014 06:40 PM, Cong Wang wrote:
> On Sun, Sep 28, 2014 at 10:50 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>>
>> I don't think we need this change, (or perhaps it needs to be a bit
>> more complete if something is missing) take a look a
>> tcf_exts_validate(), notice the policer is added to act->list so the
>> if block in dump() work out,
>
> I thought it's clear that act->list is correct here. :)
>
> I was thinking the dump logic was wrong, but you are right that
> it should match the logic in validate. Actually the bug is we forgot
> to copy exts->type, I am going to submit a patch below:
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 77147c8..aad6a67 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -549,6 +549,7 @@ void tcf_exts_change(struct tcf_proto *tp, struct
> tcf_exts *dst,
>    tcf_tree_lock(tp);
>    list_splice_init(&dst->actions, &tmp);
>    list_splice(&src->actions, &dst->actions);
> + dst->type = src->type;
>    tcf_tree_unlock(tp);
>    tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
>   #endif
>

Yep it does seem to be missing...

Although with the latest code can we just drop tcf_exts_change()
and call tcf_exts_validate() directly. I'll check in the morning
but a quick glance makes me think it should be OK and simplifies
things.

.John

-- 
John Fastabend         Intel Corporation
