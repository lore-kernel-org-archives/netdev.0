From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 02/13] net_sched: introduce qdisc_peek() helper function
Date: Wed, 5 Nov 2014 18:50:55 -0800
Message-ID: <CAM_iQpVmr3QBGCacYJaQdx7=ktHyXUNcGE=KpQwdkc+gs+j6Vg@mail.gmail.com>
References: <CAM_iQpXj6Pk3moYVKzj8YhmPz74fBgvVt4RxRMgW=+-p5MKnEg@mail.gmail.com>
	<20141105034929.GA19857@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:49807 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaKFCu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 21:50:56 -0500
Received: by mail-oi0-f45.google.com with SMTP id v63so121300oia.32
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 18:50:55 -0800 (PST)
In-Reply-To: <20141105034929.GA19857@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 7:49 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Tue, Nov 4, 2014 at 10:45 AM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> On Tue,  4 Nov 2014 09:56:25 -0800
>>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>
>>>> +static inline void qdisc_warn_nonwc(void *func, struct Qdisc *qdisc)
>>>> +{
>>>> +     if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
>>>> +             pr_warn("%pf: %s qdisc %X: is non-work-conserving?\n",
>>>> +                     func, qdisc->ops->id, qdisc->handle >> 16);
>>>> +             qdisc->flags |= TCQ_F_WARN_NONWC;
>>>> +     }
>>>> +}
>>>> +
>>>
>>> Inilining this and creating N copies of same message is not a step forward.
>>
>> Hmm, I think gcc merges same string literals when building Linux kernel?
>> But I never verify this.
>
> In general you should try to avoid inlining code that's not in
> the fast path as that leads to binary code size bloat.  As errors
> shouldn't be in the fast path this function should be inlined.

Makes sense.

Thanks!
