From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 02/13] net_sched: introduce qdisc_peek() helper function
Date: Tue, 4 Nov 2014 17:05:54 -0800
Message-ID: <CAM_iQpXj6Pk3moYVKzj8YhmPz74fBgvVt4RxRMgW=+-p5MKnEg@mail.gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	<1415123796-8093-3-git-send-email-xiyou.wangcong@gmail.com>
	<20141104104515.2e6433c6@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33895 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaKEBFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 20:05:55 -0500
Received: by mail-ob0-f179.google.com with SMTP id m8so11808187obr.38
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:05:55 -0800 (PST)
In-Reply-To: <20141104104515.2e6433c6@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 10:45 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue,  4 Nov 2014 09:56:25 -0800
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> +static inline void qdisc_warn_nonwc(void *func, struct Qdisc *qdisc)
>> +{
>> +     if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
>> +             pr_warn("%pf: %s qdisc %X: is non-work-conserving?\n",
>> +                     func, qdisc->ops->id, qdisc->handle >> 16);
>> +             qdisc->flags |= TCQ_F_WARN_NONWC;
>> +     }
>> +}
>> +
>
> Inilining this and creating N copies of same message is not a step forward.

Hmm, I think gcc merges same string literals when building Linux kernel?
But I never verify this.
