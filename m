From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 11:27:55 +0200
Message-ID: <20170424092754.GB25218@vergenet.net>
References: <20170421.113800.1367091481085913667.davem@davemloft.net>
 <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
 <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
 <20170421.121217.1268145592512455181.davem@davemloft.net>
 <c6333422-ae6d-149c-09ec-c5dfb43d68b3@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        jiri@resnulli.us, netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37319 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1167857AbdDXJ16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 05:27:58 -0400
Received: by mail-wm0-f49.google.com with SMTP id m123so61623332wma.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 02:27:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c6333422-ae6d-149c-09ec-c5dfb43d68b3@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 02:11:00PM -0400, Jamal Hadi Salim wrote:
> On 17-04-21 12:12 PM, David Miller wrote:
> 
> >Yes for existing attributes we are stuck in the mud because of how
> >we've handled things in the past.  I'm not saying we should change
> >behavior for existing attributes.
> >
> >I'm talking about any newly added attribute from here on out, and
> >that we need to require checks for them.
> >
> 
> Please bear with me. I want to make sure to get this right.
> 
> Lets say I updated the kernel today to reject transactions with
> bits it didnt understand. Lets call this "old kernel". A tc that
> understands/sets these bits and nothing else. Call it "old tc".
> 3 months later:
> I add one more bit setting to introduce a new feature in a new
> kernel version. Lets call this new "kernel". I update to
> understand new bits. Call it "new tc".
> 
> The possibilities:
> a) old tc + old kernel combo. No problem
> b) new tc + new kernel combo. No problem.
> c) old tc + new kernel combo. No problem.
> d) new tc + old kernel. Rejection.
> 
> For #d if i have a smart tc it would retry with a new combination
> which restores its behavior to old tc level. Of course this means
> apps would have to be rewritten going forward to understand these
> mechanics.
> Alternative is to request for capabilities first then doing a
> lowest common denominator request.
> But even that is a lot more code and crossing user/kernel twice.

>From my PoV, for #d user-space has to either get smart or fail.

Creating new tc involved work in order to support the new feature.
Part of that work would be a decision weather or not to provide
compatibility for old kernel or to bail out gracefully.

> There is a simpler approach that would work going forward.
> How about letting the user choose their fate? Set something maybe
> in the netlink header to tell the kernel "if you dont understand
> something I am asking for - please ignore it and do what you can".
> This would maintain current behavior but would force the user to
> explicitly state so.
> 
> cheers,
> jamal
> 
