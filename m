From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 02/13] net_sched: introduce qdisc_peek() helper function
Date: Wed, 5 Nov 2014 11:49:29 +0800
Message-ID: <20141105034929.GA19857@gondor.apana.org.au>
References: <CAM_iQpXj6Pk3moYVKzj8YhmPz74fBgvVt4RxRMgW=+-p5MKnEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41049 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaKEDte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 22:49:34 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpXj6Pk3moYVKzj8YhmPz74fBgvVt4RxRMgW=+-p5MKnEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Nov 4, 2014 at 10:45 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Tue,  4 Nov 2014 09:56:25 -0800
>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>> +static inline void qdisc_warn_nonwc(void *func, struct Qdisc *qdisc)
>>> +{
>>> +     if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
>>> +             pr_warn("%pf: %s qdisc %X: is non-work-conserving?\n",
>>> +                     func, qdisc->ops->id, qdisc->handle >> 16);
>>> +             qdisc->flags |= TCQ_F_WARN_NONWC;
>>> +     }
>>> +}
>>> +
>>
>> Inilining this and creating N copies of same message is not a step forward.
> 
> Hmm, I think gcc merges same string literals when building Linux kernel?
> But I never verify this.

In general you should try to avoid inlining code that's not in
the fast path as that leads to binary code size bloat.  As errors
shouldn't be in the fast path this function should be inlined.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
